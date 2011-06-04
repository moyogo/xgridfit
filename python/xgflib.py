from subprocess import Popen, PIPE
from re import search, compile
from sys import exit, stdout, stderr
from os.path import join, isfile, isdir, splitext, abspath, dirname
from os import access, R_OK, W_OK, pathsep, environ, remove, mkdir
from tempfile import mkstemp, TemporaryFile
from optparse import OptionParser
from time import time
try:
    import libxml2
except ImportError:
    print """
    Xgridfit depends on libxml2 and its Python bindings.
    Install these and try again.
    """
    exit(1)

VERSION = '2.2'
JAVA_EXECUTABLE = 'java'
DISPLAY_DIAGNOSTIC_MESSAGES = False
XGRIDFIT_DIR = abspath('/usr/local/share/xml/xgridfit/')
XSLT_DIR = abspath(join(XGRIDFIT_DIR, 'lib'))
UTIL_DIR = abspath(join(XGRIDFIT_DIR, 'utils'))
SCHEMA_DIR = abspath(join(XGRIDFIT_DIR, 'schemas'))
HOME_DIR = environ['HOME']
CONFIG_DIR_REL = '.xgridfit'
CONFIG_DIR = abspath(join(HOME_DIR, CONFIG_DIR_REL))
# CONFIG_DIR = HOME_DIR + '/' + CONFIG_DIR_REL
NO_PROCESSOR_ERROR = """
Could not find an XSLT processor to use. Install one of these:
    libxslt (preferably with Python bindings)
    lxml (Python bindings for libxslt)
    Saxon (preferably version 9, but 6 will do)
    Xalan (C++ or Java version)
    4Suite
If you choose one of the Java-based processors, you must run
xgfconfig to help Xgridfit find its .jar file.

"""

def diagnostic_message(msg):
    """ Displays diagnostic messages it is turned on. """
    if DISPLAY_DIAGNOSTIC_MESSAGES:
        stderr.write(msg + "\n")

def adjust_directories(new_xgridfit_dir):
    """ Change all directories if the Xgridfit root dir is changed. """
    global XGRIDFIT_DIR
    global XSLT_DIR
    global SCHEMA_DIR
    global UTIL_DIR
    XGRIDFIT_DIR = abspath(new_xgridfit_dir)
    XSLT_DIR =  abspath(join(XGRIDFIT_DIR, 'lib'))
    UTIL_DIR =  abspath(join(XGRIDFIT_DIR, 'utils'))
    SCHEMA_DIR = abspath(join(XGRIDFIT_DIR, 'schemas'))

def has_xinclude_namespace(f):
    """ Test a file for the XInclude namespace. """
    result = False
    fh = open(f, 'r')
    for line in fh.readlines():
        if line.find('http://www.w3.org/2001/XInclude') >= 0:
            result = True
            break
    fh.close()
    return result

def xinclude_temp_file(fname, tfile=None):
    """ Get a temporary file for Xinclude output. """
    xgfdoc = libxml2.parseFile(fname)
    xgfdoc.xincludeProcess()
    if tfile is None:
        tfile = mkstemp(prefix='xgf_')[1]
    xgfdoc.saveFile(tfile)
    return tfile

def have_program(filename):
    """ Search the path for a file; return true if found. """
    file_found = False
    sys_path = environ['PATH']
    paths = sys_path.split(pathsep)
    for path in paths:
        if isfile(abspath(join(path, filename))):
            diagnostic_message("found program " + filename)
            file_found = True
            break
    if not file_found:
        diagnostic_message("did not find program " + filename)
    return file_found

def findProcessor(config):
    """ 
    Read through the processor priority list and return the first one
    we think we can actually run.
    """
    proc = None
    for k in config.processor_priority:
        if Configuration.processor_classes[k].isEnabled(config):
            proc = Configuration.processor_classes[k]
            break
    return proc

def findValidator(config):
    """ 
    Read through the validator priority list and return the first one
    we think we can actually run.
    """
    val = None
    for k in config.validator_priority:
        if Configuration.validator_classes[k].isEnabled(config):
            val = Configuration.validator_classes[k]
            break
    return val

class XGFCompilationError(Exception):
    """ Error when compiling an Xgridfit program. """
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return str(self.value)

class XGFValidationError(Exception):
    """ Error when validating an Xgridfit program file. """
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return str(self.value)

class Validator():
    """ Base class for all validators. """
    def __init__(self, config, xgf, need_xinclude=False):
        self.xgffile = xgf
        self.need_xinclude = need_xinclude
        self.config = config
    @staticmethod
    def isEnabled(config):
        return False
    def execute_external(self, params):
        """ Run a validator. """
        process = Popen(params, stderr=PIPE)
        err = process.communicate()[1]
        if process.returncode != 0:
            raise XGFValidationError(err)
    def validate(self):
        pass

class LibxmlValidator(Validator):
    """ The default validator: libxml2 with Python bindings. """
    def __init__(self, config, xgf, need_xinclude=False):
        Validator.__init__(self, config, xgf, need_xinclude)
    @staticmethod
    def isEnabled(config):
        return True
    def libxmlError(self, ctxt, error):
        try:
            last_error = libxml2.lastError()
            err_str = "line " + str(last_error.line()) + \
                ": " + last_error.message()
            stderr.write(err_str)
        except Exception as d:
            stderr.write(str(d))
    def validate(self):
        diagnostic_message("Validating with libxml2 ...")
        xgfctxt = libxml2.createFileParserCtxt(self.xgffile)
        xgfctxt.parseDocument()
        xgfdoc = xgfctxt.doc()
        libxml2.registerErrorHandler(self.libxmlError, xgfctxt)
        if self.need_xinclude:
            xgfdoc.xincludeProcess()
        sc_file = abspath(join(SCHEMA_DIR, 'xgridfit.rng'))
        rngParser = libxml2.relaxNGNewParserCtxt(libxml2.pathToURI(sc_file))
        rngs = rngParser.relaxNGParse()
        ctxt = rngs.relaxNGNewValidCtxt()
        result = xgfdoc.relaxNGValidateDoc(ctxt)
        xgfdoc.freeDoc()
        if result != 0:
            raise XGFValidationError("Error validating document")

class LxmlValidator(Validator):
    """ Validator using libxml2 and an alternate set of python bindings. """
    def __init__(self, config, xgf, need_xinclude=False):
        Validator.__init__(self, config, xgf, need_xinclude)
    @staticmethod
    def isEnabled(config):
        try:
            from lxml import etree
        except ImportError:
            diagnostic_message("No lxml validator ...")
            return False
        else:
            diagnostic_message("Have lxml validator ...")
            return True
    def validate(self):
        from lxml import etree
        diagnostic_message("Validating with lxml ...")
        xgfdoc = etree.parse(self.xgffile)
        if self.need_xinclude:
            xgfdoc.xinclude()
        relaxng_doc = etree.parse(abspath(join(SCHEMA_DIR, 'xgridfit.rng')))
        relaxng = etree.RelaxNG(relaxng_doc)
        try:
            relaxng.assertValid(xgfdoc)
        except etree.DocumentInvalid as d:
            err_msg = str(d) + "\n"
            raise XGFValidationError(err_msg)

class RnvValidator(Validator):
    """ The RNV validator: very fast and friendly. """
    def __init__(self, config, xgf, need_xinclude=False):
        Validator.__init__(self, config, xgf, need_xinclude)
    @staticmethod
    def isEnabled(config):
        return have_program('rnv')
    def validate(self):
        diagnostic_message("Validating with rnv ...")
        args = ['rnv', abspath(join(SCHEMA_DIR, 'xgridfit.rnc')), self.xgffile]
        try:
            self.execute_external(args)
        except XGFValidationError:
            raise

class JingValidator(Validator):
    """ Jing validator: Java-based, so a bit slow, but does not stop on error. """
    def __init__(self, config, xgf, need_xinclude=False):
        Validator.__init__(self, config, xgf, need_xinclude)
    @staticmethod
    def isEnabled(config):
        return have_program(JAVA_EXECUTABLE) \
            and isfile(config.jar_files['jing'])
    def validate(self):
        diagnostic_message("Validating with jing ...")
        args = ['java', '-jar', self.config.jar_files['jing'],
                abspath(join(SCHEMA_DIR, 'xgridfit.rng')), self.xgffile]
        try:
            self.execute_external(args)
        except XGFValidationError:
            raise

class MsvValidator(Validator):
    """ MSV validator: good, Java-based, a bit verbose. """
    def __init__(self, config, xgf, need_xinclude=False):
        Validator.__init__(self, config, xgf, need_xinclude)
    @staticmethod
    def isEnabled(config):
        return have_program(JAVA_EXECUTABLE) \
            and isfile(config.jar_files['msv'])
    def validate(self):
        diagnostic_message("Validating with msv ...")
        args = ['java', '-jar', self.config.jar_files['msv'],
                abspath(join(SCHEMA_DIR, 'xgridfit.rng')), self.xgffile]
        try:
            self.execute_external(args)
        except XGFValidationError:
            raise

class XSLTProcessor():
    """ Base class for all XSLT processors. """
    def __init__(self, config, f, x, p, need_xinclude=False):
        self.xgffile = f
        self.params = p
        self.xslfile = x
        self.need_xinclude = need_xinclude
        self.config = config
    @staticmethod
    def isEnabled(config):
        return False
    def execute_external(self, params):
        """ Run an XSLT processor. """
        process = Popen(params, stdout=PIPE)
        output = process.communicate()[0]
        if process.returncode != 0:
            raise XGFCompilationError('Error from ' + params[0])
        return output
    def run(self):
        pass

class SaxonProcessor(XSLTProcessor):
    """ Base class for the two Saxon processors we know about (6 and 9). """
    def __init__(self, config, f, x, p, need_xinclude=False):
        XSLTProcessor.__init__(self, config, f, x, p, need_xinclude)
    def make_params(self, params):
        param_list = []
        for k in params.keys():
            param_list.append(k + '=' + params[k])
        return param_list

class SaxonNineProcessor(SaxonProcessor):
    """ The current Saxon processor: well optimized! """
    def __init__(self, config, f, x, p, need_xinclude=False):
        SaxonProcessor.__init__(self, config, f, x, p, need_xinclude)
    @staticmethod
    def isEnabled(config):
        return have_program(JAVA_EXECUTABLE) \
            and isfile(config.jar_files['saxon-9'])
    def run(self):
        diagnostic_message('Running saxon-9 processor ...')
        start_args = [JAVA_EXECUTABLE, '-classpath',
                      self.config.jar_files['saxon-9'],
                      'net.sf.saxon.Transform',
                      '-l:on',
                      '-versionmsg:off',
                      '-s:' + self.xgffile,
                      '-xsl:' + self.xslfile]
        try:
            return self.execute_external(start_args + self.make_params(self.params))
        except XGFCompilationError:
            raise

class SaxonSixProcessor(SaxonProcessor):
    """ The Saxon 6 processor, still widely used. """
    def __init__(self, config, f, x, p, need_xinclude=False):
        SaxonProcessor.__init__(self, config, f, x, p, need_xinclude)
    @staticmethod
    def isEnabled(config):
        return have_program(JAVA_EXECUTABLE) \
            and isfile(config.jar_files['saxon-6'])
    def run(self):
        diagnostic_message('Running saxon-6 processor ...')
        start_args = [JAVA_EXECUTABLE, '-classpath',
                      self.config.jar_files['saxon-6'],
                      'com.icl.saxon.StyleSheet',
                      '-l',
                      self.xgffile,
                      self.xslfile]
        try:
            return self.execute_external(start_args + self.make_params(self.params))
        except XGFCompilationError:
            raise

class XalanJProcessor(XSLTProcessor):
    """
    The Xalan-Java processor: current Ubuntu version (Jan. 2010) has a
    bug that prevents it from stopping on error, so this appears
    pretty far down the priority list.
    """
    def __init__(self, config, f, x, p, need_xinclude=False):
        XSLTProcessor.__init__(self, config, f, x, p, need_xinclude)
    @staticmethod
    def isEnabled(config):
        return have_program(JAVA_EXECUTABLE) \
            and isfile(config.jar_files['xalan-j'])
    def run(self):
        diagnostic_message('Running xalan-j processor ...')
        param_list = []
        for k in self.params.keys():
            param_list += ['-param', k, self.params[k]]
        start_args = [JAVA_EXECUTABLE,
                      '-classpath',
                      self.config.jar_files['xalan-j'],
                      'org.apache.xalan.xslt.Process',
                      '-l',
                      '-in',
                      self.xgffile,
                      '-xsl',
                      self.xslfile]
        try:
            return self.execute_external(start_args + param_list)
        except XGFCompilationError:
            raise

class XsltprocProcessor(XSLTProcessor):
    """
    Runs the external xsltproc program. Use this if the python binding
    for libxslt is not installed.
    """
    def __init__(self, config, f, x, p, need_xinclude=False):
        XSLTProcessor.__init__(self, config, f, x, p, need_xinclude)
    @staticmethod
    def isEnabled(config):
        return have_program('xsltproc')
    def run(self):
        diagnostic_message('Running xsltproc processor ...')
        param_list = []
        for k in self.params.keys():
            this_param = ['--stringparam', k, self.params[k]]
            param_list += this_param
        start_args = ['xsltproc']
        if self.need_xinclude:
            start_args += ['--xinclude']
        end_args = [self.xslfile, self.xgffile]
        all_args = start_args + param_list + end_args
        if DISPLAY_DIAGNOSTIC_MESSAGES:
            stderr.write(str(all_args))
        try:
            return self.execute_external(all_args)
        except XGFCompilationError:
            raise

class XalanCProcessor(XSLTProcessor):
    """
    The Xalan C++ processor: good, fast, but unnecessarily verbose.
    """
    def __init__(self, config, f, x, p, need_xinclude=False):
        XSLTProcessor.__init__(self, config, f, x, p, need_xinclude)
    @staticmethod
    def isEnabled(config):
        return have_program('xalan')
    def run(self):
        diagnostic_message('Running xalan-c processor ...')
        param_list = []
        for k in self.params.keys():
            param_list += ['-param', k, "'" + self.params[k] + "'"]
        start_args = ['xalan', '-in', self.xgffile, '-xsl', self.xslfile]
        try:
            return self.execute_external(start_args + param_list)
        except XGFCompilationError:
            raise

class LibxsltProcessor(XSLTProcessor):
    """
    The default processor: libxslt with its Python bindings.
    """
    def __init__(self, config, f, x, p, need_xinclude=False):
        XSLTProcessor.__init__(self, config, f, x, p, need_xinclude)
        self.xslt_error = False
    @staticmethod
    def isEnabled(config):
        try:
            import libxslt
        except ImportError:
            diagnostic_message("No libxslt ...")
            return False
        else:
            diagnostic_message("Have libxslt ...")
            return True
    def libxsltError(self, ctxt, error):
        stderr.write(error)
        if error.find("Error") >= 0:
            self.xslt_error = True
    def run(self):
        diagnostic_message('Running libxslt processor ...')
        import libxslt
        xgfdoc = libxml2.parseFile(self.xgffile)
        if self.need_xinclude:
            xgfdoc.xincludeProcess()
        styledoc = libxml2.parseFile(self.xslfile)
        style = libxslt.parseStylesheetDoc(styledoc)
        newparams = dict()
        for k in self.params.keys():
            newparams[k] = "'" + str(self.params[k]) + "'"
        libxslt.registerErrorHandler(self.libxsltError,
                                     style.newTransformContext(xgfdoc))
        result = style.applyStylesheet(xgfdoc, newparams)
        if self.xslt_error:
            raise XGFCompilationError('Error from libxslt')
        s = style.saveResultToString(result)
        xgfdoc.freeDoc()
        result.freeDoc()
        styledoc.freeDoc()
        return s

class LxmlProcessor(XSLTProcessor):
    """
    The lxml Python bindings for libxslt. Very good, but does not
    display messages while running.
    """
    def __init__(self, config, f, x, p, need_xinclude=False):
        XSLTProcessor.__init__(self, config, f, x, p, need_xinclude)
    @staticmethod
    def isEnabled(config):
        try:
            from lxml import etree
        except ImportError:
            diagnostic_message("No lxml ...")
            return False
        else:
            diagnostic_message("Using lxml ...")
            return True
    def run(self):
        diagnostic_message('Running lxml processor ...')
        from lxml import etree
        xgfdoc = etree.parse(self.xgffile)
        if self.need_xinclude:
            xgfdoc.xinclude()
        styledoc = etree.parse(self.xslfile)
        transform = etree.XSLT(styledoc)
        newparams = {'silent_mode': "'yes'"}
        for k in self.params.keys():
            newparams[k] = "'" + self.params[k] + "'"
        # Since lxml won't display messages while running, suppress the
        # routine ones.
        try:
            result = transform(xgfdoc, **newparams)
            # print any warnings after the run.
            if len(transform.error_log) > 0:
                for e in transform.error_log:
                    stderr.write(str(e) + "\n")
        except etree.XSLTApplyError as msg:
            raise XGFCompilationError(msg)
        return(str(result))

class FourSuiteProcessor(XSLTProcessor):
    """
    An XSLT processor written in Python. Good, but slow and verbose.
    """
    def __init__(self, config, f, x, p, need_xinclude=False):
        XSLTProcessor.__init__(self, config, f, x, p, need_xinclude)
    @staticmethod
    def isEnabled(config):
        try:
            from Ft.Xml import InputSource
            from Ft.Lib.Uri import OsPathToUri
            from Ft.Xml.Xslt import Processor, XsltRuntimeException
        except ImportError:
            diagnostic_message("No 4Suite ...")
            return False
        else:
            diagnostic_message("Have 4Suite ...")
            return True
    def run(self):
        diagnostic_message('Running 4Suite processor ...')
        from Ft.Xml import InputSource
        from Ft.Lib.Uri import OsPathToUri
        from Ft.Xml.Xslt import Processor, XsltRuntimeException
        processor = Processor.Processor()
        srcAsUri = OsPathToUri(self.xgffile)
        source = InputSource.DefaultFactory.fromUri(srcAsUri)
        ssAsUri = OsPathToUri(self.xslfile)
        transform = InputSource.DefaultFactory.fromUri(ssAsUri)
        processor.appendStylesheet(transform)
        try:
            result = processor.run(source, topLevelParams=self.params)
        except XsltRuntimeException as msg:
            raise XGFCompilationError(msg)
        return result

class InstructionSet:
    """
    A set of instructions (for a glyph, function or prep table), read
    in as a newline-delimited string, parsed, output as a series of
    Xgridfit <command> and <push> elements, and stored in a libxml2
    xmlNode object.
    """
    push_test = compile(r"PUSH[BW]")
    alpha_test = compile(r"[A-Z]+")
    num_test = compile(r"[0-9]+")
    instcomp = compile(r"[A-Z0-5]+")
    mod1comp = compile(r"\[[01]+\]")
    mod2comp = compile(r"[01]+")
    def __init__(self, s):
        self.raw_instruction_string = s
        self.instruction_list = self.raw_instruction_string.split("\n")
    def line_type(self, ln):
        if search(InstructionSet.push_test, ln):
            return "push"
        if search(InstructionSet.num_test, ln) and not search(InstructionSet.alpha_test, ln):
            return "num"
        if len(ln.strip()) < 1:
            return "empty"
        return "inst"
    def get_instruction(self, ln):
        instr = search(InstructionSet.instcomp, ln).group(0)
        res2 = search(InstructionSet.mod1comp, ln)
        if res2:
            modif = search(InstructionSet.mod2comp, res2.group(0)).group(0)
        else:
            modif = None
        return (instr, modif)
    def parse_and_install(self, parent_element):
        num_string = ""
        last_type = "first"
        for i in self.instruction_list:
            current_type = self.line_type(i)
            # diagnostic_message("\ntype of \"" + i + "\": " + current_type + "\n")
            if current_type != "num" and last_type == "num":
                parent_element.newChild(None, "push", num_string)
                num_string = ""
            if current_type == "inst":
                inst, mod = self.get_instruction(i)
                inst_elem = parent_element.newChild(None, "command", None)
                inst_elem.setProp("name", inst)
                if mod is not None:
                    inst_elem.setProp("modifier", mod)
            if current_type == "num":
                if len(num_string) > 0:
                    num_string += " "
                num_string += i.strip()
            last_type = current_type
        if current_type == "num":
            parent_element.newChild(None, "push", num_string)

class TTXOptions:
    """ Options for the utility ttx2xgf. """
    def __init__(self):
        global DISPLAY_DIAGNOSTIC_MESSAGES
        usage_message = "\nttx2xgf infile[.ttx] [outfile]"
        self.opt_pars = OptionParser(usage_message)
        self.opt_pars.add_option("--config",
                                 dest="config_file",
                                 metavar="file",
                                 help="full pathname of an Xgridfit configuration file")
        self.opt_pars.add_option("-e", action="store_true", default=False,
                                 dest="display_diagnostic",
                                 help="display diagnostic messages (for debugging)")
        self.opt_pars.add_option("-E", "--elapsed-time", action="store_true",
                                 dest="elapsed_time", default=False,
                                 help="report the time (in seconds) used for this run \
of ttx2xgf")
        self.opt_pars.add_option("--processor", dest="preferred_processor",
                                 metavar="libxslt|lxml|xsltproc|saxon-6|saxon-9|xalan-j|\
xalan-c|4xslt",
                                 help="preferred XSLT processor")
        (opts, self.args) = self.opt_pars.parse_args()
        DISPLAY_DIAGNOSTIC_MESSAGES = opts.display_diagnostic
        self.config_file = opts.config_file
        self.elapsed_time = opts.elapsed_time
        self.preferred_processor = opts.preferred_processor
        self.preferred_validator = None

class MergeOptions:
    def __init__(self):
        global DISPLAY_DIAGNOSTIC_MESSAGES
        usage_message = "\nxgfmerge [options] file-a file-b [...]"
        self.opt_pars = OptionParser(usage_message)
        self.opt_pars.add_option("--config",
                                 dest="config_file",
                                 metavar="file",
                                 help="full pathname of an Xgridfit configuration file")
        self.opt_pars.add_option("-e", "-v", action="store_true", default=False,
                                 dest="display_diagnostic",
                                 help="display diagnostic messages (for debugging)")
        self.opt_pars.add_option("-E", "--elapsed-time", action="store_true",
                                 dest="elapsed_time", default=False,
                                 help="report the time (in seconds) used for this run \
of ttx2xgf")
        self.opt_pars.add_option("--processor", dest="preferred_processor",
                                 metavar="libxslt|lxml|xsltproc|saxon-6|saxon-9|xalan-j|\
xalan-c|4xslt",
                                 help="preferred XSLT processor")
        self.opt_pars.add_option("-c", "--use-compile-globals",
                                 dest="use_compile_globals",
                                 action="store_true",
                                 default=False,
                                 help="ignore globals in files other than file-a when \
value of \"compile-globals\" default is \"no\"")
        self.opt_pars.add_option("-n", "--include-no-compile",
                                 dest="skip_b_no_compile",
                                 action="store_false",
                                 default=True,
                                 help="Include <no-compile> element")
        self.opt_pars.add_option("-o", "--out",
                                 dest="output_file",
                                 metavar="file",
                                 help="Write result to file (otherwise to stdout)")
        self.opt_pars.add_option("-p", "--replace-pre-program",
                                 dest="prep_mode",
                                 action="store_true",
                                 default=False,
                                 help="Prefer <pre-program> from file other than file-a")
        self.opt_pars.add_option("-s", "--sort",
                                 dest="sort_glyphs",
                                 action="store_true",
                                 default=False,
                                 help="Sort glyph elements in output")
        self.opt_pars.add_option("-x", "--xinclude",
                                 dest="resolve_xincludes",
                                 action="store_true",
                                 default=False,
                                 help="Resolve XIncludes (except from file-a)")
        (opts, self.args) = self.opt_pars.parse_args()
        self.params = {}
        if opts.use_compile_globals:
            params["use_compile_globals"] = "yes"
        if not opts.skip_b_no_compile:
            params["skip_b_no_compile"] = "no"
        if opts.prep_mode:
            params["prep_mode"] = "priority"
        DISPLAY_DIAGNOSTIC_MESSAGES = opts.display_diagnostic
        self.elapsed_time = opts.elapsed_time
        self.config_file = opts.config_file
        self.preferred_processor = opts.preferred_processor
        self.output_file = opts.output_file
        self.sort_glyphs = opts.sort_glyphs
        self.resolve_xincludes = opts.resolve_xincludes

class ConfigOptions:
    def __init__(self):
        """
        After this runs, precisely one of processors, validators or
        xgridfit_dir must be true, and we must have a list of arguments
        in args. These must be in the format saxon-9 or
        saxon-9=/path/to/saxon9.jar, quoted if it contains spaces. We
        exit with an error message if more than one of processors,
        validators, or xgridfit_dir is True or if the args list is
        empty.
        """
        usage_message = "\nxgfconfig options list"
        self.opt_pars = OptionParser(usage_message)
        self.opt_pars.add_option("--config",
                                 dest="config_file",
                                 metavar="file",
                                 help="Xgridfit configuration file to read and write")
        self.opt_pars.add_option("-p", "--processors",
                                 dest="processors",
                                 action="store_true",
                                 default=False,
                                 help="processor list follows")
        self.opt_pars.add_option("-s", "--show", action="store_true",
                                 default=False, dest="show_config",
                                 help="display the current configuration")
        self.opt_pars.add_option("-V", "--validators",
                                 dest="validators",
                                 action="store_true",
                                 default=False,
                                 help="validator list follows")
        self.opt_pars.add_option("-x", "--xgridfit-dir",
                                 dest="xgridfit_dir",
                                 action="store_true",
                                 default=False,
                                 help="Xgridfit base directory follows")
        (opts, self.args) = self.opt_pars.parse_args()
        self.processors = opts.processors
        self.validators = opts.validators
        self.xgridfit_dir = opts.xgridfit_dir
        self.config_file = opts.config_file
        self.show_config = opts.show_config
        if (self.processors and (self.validators or self.xgridfit_dir)) or \
                (self.validators and self.xgridfit_dir):
            stderr.write("You may specify only one of --processors, \
--validators or --xgridfit-dir\n")
            exit(1)
        if not self.processors and not self.validators and \
                not self.show_config and not self.xgridfit_dir:
            stderr.write("\nError: Nothing to do!\n\n")
            self.opt_pars.print_help()
            exit(1)
        if len(self.args) < 1 and not self.show_config:
            err_msg = "You must "
            if self.processors or self.validators:
                err_msg += "list the name of at least one "
            if self.processors:
                err_msg += "processor\n"
            if self.validators:
                err_msg += "validator\n"
            if self.xgridfit_dir:
                err_msg += "supply the location of the Xgridfit base directory\n"
            stderr.write(err_msg)
            exit(1)

class OptionsAndArgs:
    """ Options for the utility xgfconfig. """
    def __init__(self):
        global DISPLAY_DIAGNOSTIC_MESSAGES
        usage_message = "\nxgridfit [options] file.{xgf or xml} ..."
        self.opt_pars = OptionParser(usage_message)
        self.opt_pars.add_option("-a", "--max-stack", type="int",
                                 dest="max_stack", metavar="num",
                                 help="size of TrueType stack")
        self.opt_pars.add_option("-A", "--auto-instr", action="store_true",
                                 dest="auto_instr",
                                 help="auto-instruct the font before installing \
Xgridfit programming (merge-mode only)")
        self.opt_pars.add_option("-b", "--delta-break", type="int",
                                 dest="delta_break", metavar="num",
                                 help="delta break value")
        self.opt_pars.add_option("-c", "--compile-globals",
                                 choices=['yes', 'no'], dest="compile_globals",
                                 metavar="yes|no",
                                 help="compile functions, control values, \
pre-program and maxp entries (default is \"yes\")")
        self.opt_pars.add_option("-C", "--color",
                                 choices=['black', 'white', 'gray', 'grey'],
                                 dest="color",
                                 metavar="black|white|gray|grey",
                                 help="default color of rounded distances (default \
is \"gray\")")
        self.opt_pars.add_option("--config",
                                 dest="config_file",
                                 metavar="file",
                                 help="full pathname of an Xgridfit configuration file")
        self.opt_pars.add_option("-d", "--debug-mode", action="store_true",
                                 dest="debug_mode", default=False,
                                 help="run in debug mode (output file has extension \
.debug)")
        self.opt_pars.add_option("-D", "--delete-all", action="store_true",
                                 dest="delete_all",
                                 help="delete all instruction-related info before \
installing Xgridfit programming (merge-mode only)")
        self.opt_pars.add_option("-e", action="store_true", default=False,
                                 dest="display_diagnostic",
                                 help="display diagnostic messages (for debugging)")
        self.opt_pars.add_option("-E", "--elapsed-time", action="store_true",
                                 dest="elapsed_time", default=False,
                                 help="report the time (in seconds) used for this \
run of Xgridfit")
        self.opt_pars.add_option("-f", "--execute", action="store_true",
                                 dest="execute", default=False,
                                 help="execute the generated script; do not save")
        self.opt_pars.add_option("-F", "--data-file", dest="data_file",
                                 metavar="filename",
                                 help="Store font information in a file instead \
of in FontForge's font.persistent object (merge-mode only)")
        self.opt_pars.add_option("-g", "--glyph-select", dest="glyph_select",
                                 metavar="glyph+list",
                                 help="compile only glyphs in this list (delimit \
with +)")
        self.opt_pars.add_option("-G", "--init-graphics", choices=['yes', 'no'],
                                 dest="init_graphics",
                                 metavar="yes|no",
                                 help="initialize graphics state tracking in glyph \
programs (default is \"yes\")")
        self.opt_pars.add_option("-H", "--auto-hint",
                                 choices=['yes', 'no'],
                                 dest="auto_hint",
                                 metavar="yes|no",
                                 help="auto-hint the font before auto-instructing \
(default is \"yes\"; has no effect except with --auto-instr; merge-mode only)")
        self.opt_pars.add_option("-i", "--infile", dest="infile",
                                 metavar="filename",
                                 help="file to be input by generated script")
        self.opt_pars.add_option("-l", "--language", choices=['ff', 'py'],
                                 dest="language", default="py",
                                 metavar="py|ff",
                                 help="language of script to be output: Python \
or native FontForge (default is \"py\")")
        self.opt_pars.add_option("-m", "--merge-mode", action="store_true",
                                 dest="merge_mode", default=False,
                                 help="run in merge-mode")
        self.opt_pars.add_option("-o", "--outfile",
                                 dest="outfile",
                                 metavar="filename",
                                 help="file to be output by generated script")
        self.opt_pars.add_option("-O", "--output-script", dest="output_script",
                                 metavar="filename",
                                 help="script file to be output by Xgridfit")
        self.opt_pars.add_option("-p", "--push-break", type="int",
                                 dest="push_break", metavar="num",
                                 help="push break value")
        self.opt_pars.add_option("-P", "--combine-prep", choices=['yes', 'no'],
                                 dest="combine_prep", metavar="yes|no",
                                 help="combine Xgridfit pre-program with the \
font's prep table (merge-mode only; default is \"yes\")")
        self.opt_pars.add_option("--processor", dest="preferred_processor",
                                 metavar="libxslt|lxml|xsltproc|saxon-6|saxon-9|\
xalan-j|xalan-c|4xslt",
                                 help="preferred XSLT processor")
        self.opt_pars.add_option("-q", "--quiet", action="store_true",
                                 dest="silent_mode",
                                 help="run in quiet mode")
        self.opt_pars.add_option("-s", "--max-storage", type="int",
                                 dest="max_storage", metavar="num",
                                 help="max places in storage area (variables)")
        self.opt_pars.add_option("-S", "--output-base",
                                 dest="outfile_base", metavar="name",
                                 help="save script for each glyph in file \
name_glyphname.pe|py (does not work in merge-mode)")
        self.opt_pars.add_option("--skip-validation", action="store_false",
                                 dest="validate", default=True,
                                 help="skip Relax NG validation")
        self.opt_pars.add_option("-t", "--max-twilight", type="int",
                                 dest="max_twilight", metavar="num",
                                 help="max points in twilight zone")
        self.opt_pars.add_option("-T", "--temp-file", dest="temp_file",
                                 metavar="filename",
                                 help="temporary file for XInclude results")
        self.opt_pars.add_option("-v", "--version", action="store_true",
                                 dest="version", default=False,
                                 help="show version number and exit")
        self.opt_pars.add_option("-V", action="store_true",
                                 dest="dummy_validate", default=False,
                                 help="Validate Xgridfit program before compiling \
(has no effect since the default is now yes)")
        self.opt_pars.add_option("--validator", dest="preferred_validator",
                                 metavar="libxml2|lxml|jing|msv|rnv",
                                 help="preferred Relax NG validator")

        self.opt_pars.add_option("-x", "--skip-compilation",
                                 action="store_true", dest="skip_compilation",
                                 default=False,
                                 help="Do not compile. Validation is performed if \
--skip-validation does not block it")
        self.opt_pars.add_option("-X", "--no-xinclude", action="store_false",
                                 dest="perform_xinclude_check", default=True,
                                 help="Assume that XInclude is unnecessary; \
do not check")
        self.opt_pars.add_option("-z", "--output-outfile-script",
                                 dest="outfile_script_name", metavar="name",
                                 help="name of separate script file for output of \
<outfile> (works only with option --output-base)")
        (opts, self.args) = self.opt_pars.parse_args()
        self.params = {'max_stack': None, 'auto_instr': None,
                       'delta_break': None, 'compile_globals': None,
                       'color': None, 'delete_all': None,
                       'data_file': None, 'glyph_select': None,
                       'init_graphics': None,
                       'auto_hint': None, 'infile': None,
                       'outfile': None, 'push_break': None,
                       'push_break': None, 'combine_prep': None,
                       'silent_mode': None, 'max_storage': None,
                       'outfile_base': None, 'outfile_script_name': None,
                       'max_twilight': None}
        # Extract all the params that have got to be passed to the
        # XSLT processor and put them in self.params (but we pass
        # 'yes' not True).
        for k in opts.__dict__.keys():
            if k in self.params:
                int_val = opts.__dict__[k]
                if int_val is not None:
                    if int_val == True:
                        int_val = 'yes'
                    if int_val == False:
                        int_val = 'no'
                    if type(int_val) is int:
                        int_val = str(int_val)
                    self.params[k] = int_val
        # Discard any undefined params.
        for k in self.params.keys():
            if self.params[k] is None:
                del self.params[k]
        if DISPLAY_DIAGNOSTIC_MESSAGES:
            stderr.write("Parameters:\n")
            stderr.write(str(self.params))
        # These are the params we deal with in this script; they are
        # not passed to the XSLT processor.
        DISPLAY_DIAGNOSTIC_MESSAGES = opts.display_diagnostic
        self.config_file = opts.config_file
        self.debug_mode = opts.debug_mode
        self.elapsed_time = opts.elapsed_time
        self.execute = opts.execute
        self.language = opts.language
        self.merge_mode = opts.merge_mode
        self.output_script = opts.output_script
        self.temp_file = opts.temp_file
        self.version = opts.version
        self.validate = opts.validate
        self.perform_xinclude_check = opts.perform_xinclude_check
        self.skip_compilation = opts.skip_compilation
        self.preferred_processor = opts.preferred_processor
        self.preferred_validator = opts.preferred_validator
        # fixups: certain options are incompatible.
        if self.merge_mode:
            self.language = 'py'
            if 'outfile_base' in self.params:
                del self.params['outfile_base']
            if 'outfile_script_name' in self.params:
                del self.params['outfile_script_name']
        if self.debug_mode or 'outfile_base' in self.params:
            self.execute = False

class Configuration():
    """
    Reads and manages a configuration file, which stores a user's
    preferred processor and validator, and also an Xgridfit base
    directory, if different from the default. To do: permit default
    Xgridfit options.
    """
    default_validator_priority = ['libxml2', 'lxml', 'rnv', 'jing', 'msv']
    default_processor_priority = ['libxslt', 'saxon-9', 'xsltproc', 'xalan-c',
                                  'lxml', 'saxon-6', '4xslt', 'xalan-j']
    processor_jar_files = ['saxon-9', 'saxon-6', 'xalan-j']
    validator_jar_files = ['jing', 'msv']
    java_progs = processor_jar_files + validator_jar_files
    default_jar_files = {'saxon-9': '/usr/share/java/saxon9.jar',
                         'saxon-6': '/usr/share/java/saxon.jar',
                         'xalan-j': '/usr/share/java/xalan2.jar',
                         'jing': '/usr/share/java/jing.jar',
                         'msv': '/usr/share/java/msv/msv.jar'}
    validator_classes = {'lxml': LxmlValidator,
                         'libxml2': LibxmlValidator,
                         'rnv': RnvValidator,
                         'jing': JingValidator,
                         'msv': MsvValidator}
    processor_classes = {'libxslt': LibxsltProcessor,
                         'lxml': LxmlProcessor,
                         'xsltproc': XsltprocProcessor,
                         'xalan-c': XalanCProcessor,
                         'saxon-9': SaxonNineProcessor,
                         'saxon-6': SaxonSixProcessor,
                         '4xslt': FourSuiteProcessor,
                         'xalan-j': XalanJProcessor}
    default_xgridfit_dir = XGRIDFIT_DIR
    def __init__(self, config_file=None, write_access_needed=False):
        """ Reads a config file and stores the content in a usable form. """
        self.validator_priority = list(Configuration.default_validator_priority)
        self.processor_priority = list(Configuration.default_processor_priority)

        self.jar_files = Configuration.default_jar_files.copy()
        if config_file is not None:
            self.config_file = config_file
        else:
            self.config_file = self.__find_config_file(write_access_needed)
            diagnostic_message("Using config file " + self.config_file)
        try:
            self.processor_priority = self.__read_config_list(self.processor_priority,
                                                       "processor")
            self.validator_priority = self.__read_config_list(self.validator_priority,
                                                       "validator")
            new_xgridfit_dir = self.__get_config_item('xgridfit-dir', None)
            if new_xgridfit_dir is not None:
                if isdir(new_xgridfit_dir):
                    adjust_directories(new_xgridfit_dir)
                else:
                    stderr.write(new_xgridfit_dir + " is not a directory\n")
        except libxml2.parserError:
            stderr.write("Could not read configuration file " + self.config_file + "\n")
        if DISPLAY_DIAGNOSTIC_MESSAGES:
            stderr.write("New processor priority:\n")
            stderr.write(str(self.processor_priority))
            stderr.write("New validator priority:\n")
            stderr.write(str(self.validator_priority))
            stderr.write("New jar file dict:\n")
            stderr.write(str(self.jar_files))
    def show_current_config(self):
        """ Print the current configuration on the console. """
        stdout.write("Current configuration file: ")
        if isfile(self.config_file):
            stdout.write(self.config_file)
        else:
            stdout.write("None (this is the default configuration)")
        stdout.write("\n")
        print "Processors in order of preference:"
        for p in self.processor_priority:
            stdout.write("  " + p)
            if p in self.jar_files:
                stdout.write(" (" + self.jar_files[p] + ")")
            stdout.write("\n")
        print "Validators in order of preference:"
        for v in self.validator_priority:
            stdout.write("  " + v)
            if v in self.jar_files:
                stdout.write(" (" + self.jar_files[v] + ")")
            stdout.write("\n")
        print "Xgridfit base directory: "
        print " ", XGRIDFIT_DIR
    def __processor_jar_files_changed(self):
        """ True if the current list of processor jar files differs from the default """
        changed = False
        for p in Configuration.processor_jar_files:
            if self.jar_files[p] != Configuration.default_jar_files[p]:
                changed = True
                break
        return changed
    def __validator_jar_files_changed(self):
        """ True if the current list of validator jar files differs from the default """
        changed = False
        for v in Configuration.validator_jar_files:
            if self.jar_files[v] != Configuration.default_jar_files[v]:
                changed = True
                break
        return changed
    def save_file(self):
        """ Saves the file, with whatever needs saving. """
        cfgdoc = libxml2.newDoc("1.0")
        cfgdoc.newChild(None, "xgfconfig", None)
        ctxt = cfgdoc.xpathNewContext()
        root_node = ctxt.xpathEval("/xgfconfig")[0]
        if self.processor_priority != Configuration.default_processor_priority or \
                self.__processor_jar_files_changed():
            for pv in self.processor_priority:
                new_node = root_node.newChild(None, "processor", pv)
                if pv in self.jar_files:
                    new_node.setProp("jar", self.jar_files[pv])
        if self.validator_priority != Configuration.default_validator_priority or \
                self.__validator_jar_files_changed():
            for pv in self.validator_priority:
                new_node = root_node.newChild(None, "validator", pv)
                if pv in self.jar_files:
                    new_node.setProp("jar", self.jar_files[pv])
        if Configuration.default_xgridfit_dir != XGRIDFIT_DIR:
            dir_node = ctxt.xpathEval("/xgfconfig/xgridfit-dir")
            if len(dir_node) > 0:
                dir_node[0].content = XGRIDFIT_DIR
            else:
                root_node.newChild(None, "xgridfit-dir", XGRIDFIT_DIR)
        if CONFIG_DIR == dirname(self.config_file) and not isdir(CONFIG_DIR):
            mkdir(CONFIG_DIR)
        cfgdoc.saveFormatFile(self.config_file, 1)
    def __read_config_list(self, prog_list, tag):
        """
        Read a configuration file and use the data found there to reorder
        a priority list and revise a dictionary containing the locations
        of jar files.
        """
        if isfile(self.config_file):
            diagnostic_message("Reading config file " + self.config_file)
            if DISPLAY_DIAGNOSTIC_MESSAGES:
                stderr.write("Old priority list:\n")
                stderr.write(str(prog_list))
            doc = libxml2.parseFile(self.config_file)
            ctxt = doc.xpathNewContext()
            node_name = "/xgfconfig/" + tag
            node_list = ctxt.xpathEval(node_name)
            if len(node_list) > 0:
                new_priority = []
                for n in node_list:
                    p_name = n.content.strip()
                    if p_name in prog_list:
                        diagnostic_message("have ref to program " + p_name)
                        new_priority.append(p_name)
                        if p_name in Configuration.java_progs:
                            ctxt.setContextNode(n)
                            jar = ctxt.xpathEval("@jar")
                            if len(jar) > 0:
                                diagnostic_message("have ref to jar " + jar[0].content)
                                j_file = jar[0].content
                                if isfile(j_file):
                                    self.jar_files[p_name] = j_file
                                else:
                                    diagnostic_message("have no ref to jar " + j_file + "\n")
                for p in prog_list:
                    if not p in new_priority:
                        new_priority.append(p)
            else:
                new_priority = prog_list
            doc.freeDoc()
            ctxt.xpathFreeContext()
        else:
            new_priority = prog_list
        return new_priority
    def adjust_configuration(self, opts):
        """ Adjust the configuration using stuff from the command line. """
        if opts.preferred_processor is not None:
            try:
                self.processor_priority.remove(opts.preferred_processor)
            except ValueError:
                stderr.write("There id no processor " + opts.preferred_processor + "\n")
            else:
                self.processor_priority.insert(0, opts.preferred_processor)
        if opts.preferred_validator is not None:
            try:
                self.validator_priority.remove(opts.preferred_validator)
            except ValueError:
                stderr.write("There id no validator " + opts.preferred_validator + "\n")
            else:
                self.validator_priority.insert(0, opts.preferred_validator)
    def __get_config_item(self, tag, default_value=None):
        """ Retrieve an item from the configuration file. """
        result = default_value
        if isfile(self.config_file):
            diagnostic_message("Retrieving item " + tag + " from " + self.config_file)
            doc = libxml2.parseFile(self.config_file)
            ctxt = doc.xpathNewContext()
            node_name = "/xgfconfig/" + tag
            node_list = ctxt.xpathEval(node_name)
            if len(node_list) > 0:
                result = node_list[0].content
            doc.freeDoc()
            ctxt.xpathFreeContext()
        diagnostic_message("Result is " + str(result))
        return result
    def __find_config_file(self, write_access_needed):
        """
        Find the configuration file, or a location for the file, where we
        have the appropriate permission. If we don't need write access, we
        first look for a local file config.xml, then in the user's config
        directory, then in the Xgridfit base directory. If write access
        *is* needed, we try first for the local file, then in the Xgridfit
        base directory, finally in the user's config directory. So running
        xgfconfig as root should normally change the default configuration
        system-wide.
        """
        access_mode = R_OK
        if write_access_needed:
            access_mode |= W_OK
        fname = "config.xml"
        sys_fname = join(XGRIDFIT_DIR, fname)
        default_fname = join(CONFIG_DIR, fname)
        if not write_access_needed:
            if isfile(fname) and access(fname, access_mode):
                return(fname)
            if isfile(default_fname) and access(default_fname, access_mode):
                return(default_fname)
            if isfile(sys_fname) and access(sys_fname, access_mode):
                return(sys_fname)
            return(default_fname)
        else:
            if isfile(fname) and access(fname, access_mode):
                return(fname)
            if access(XGRIDFIT_DIR, access_mode):
                return(sys_fname)
            return(default_fname)
    def parse_priority_list(self, priority_list, target_list):
        """
        priority_list is a list of processor or validator names, optionally
        followed by a hash sign and the pathname of a jar file.
        target_list is edited so that the items in priority_list are deleted
        from their original positions in the list and prepended to it.  If
        a jar file is specified and we know that the app in question needs
        one, then we associate the jar file with the app in self.jar_files.
        Note that this method changes priority_list in place, assuming that
        we have no further use for it.
        """
        priority_list.reverse()
        for p in priority_list:
            jar_item = None
            if p.find('#') >= 0:
                priority_item, jar_item = p.split('#', 1)
            else:
                priority_item = p
            if priority_item in target_list:
                del target_list[target_list.index(priority_item)]
                target_list.insert(0, priority_item)
                if jar_item is not None:
                    if priority_item in self.jar_files:
                        if isfile(jar_item):
                            self.jar_files[priority_item] = jar_item
                        else:
                            stderr.write("File " + jar_item + " does not exist\n")
                    else:
                        stderr.write("Program " + priority_item + " does not require a jar file\n")
            else:
                stderr.write("I don't know a processor or validator " + priority_item + "\n")
                exit(1)

def run_xgridfit(xgfdir="/usr/local/share/xml/xgridfit/"):
    XGRIDFIT_DIR = abspath(xgfdir)
    """ Validates and compiles an Xgridfit program. """
    start_time = time()
    # Parse the command line.
    options_and_args = OptionsAndArgs()
    if options_and_args.version:
        print VERSION
        return True
    # Choose the XSLT script we want.
    xsl_file = 'xgridfit-python.xsl'
    if options_and_args.debug_mode:
        xsl_file = 'xgridfit-debug.xsl'
    if options_and_args.merge_mode:
        xsl_file = 'xgridfit-merge.xsl'
    if options_and_args.language == 'ff':
        xsl_file = 'xgridfit.xsl'
    # Anything to do?
    if len(options_and_args.args) < 1:
        stderr.write("\n\nError: No Xgridfit file specified!\n\n")
        options_and_args.opt_pars.print_help()
        return False
    # Read configuration file and consult command line for validator and
    # processor priorities.
    config = Configuration(config_file=options_and_args.config_file,
                           write_access_needed=False)
    config.adjust_configuration(options_and_args)
    # Find an XSLT processor.
    if not options_and_args.skip_compilation:
        processor = findProcessor(config)
        if processor is None:
            stderr.write(NO_PROCESSOR_ERROR)
            return False
    # Find a Relax NG validator.
    if options_and_args.validate:
        validator = findValidator(config)
        if validator is None:
            options_and_args.validate = False
            system.stderr.write("Can't find a validator: skipping validation\n")
    error_free = True
    # Process each file on the command line.
    for xgf_file in options_and_args.args:
        original_xgf_file = xgf_file
        # Do we have the file?
        if not isfile(xgf_file):
            stderr.write("Can't find file " + xgf_file + "\n")
            return False
        # Check if we need XInclude.
        if options_and_args.perform_xinclude_check:
            need_xinclude = has_xinclude_namespace(xgf_file)
        else:
            need_xinclude = False
        ffscript = None
        delete_temp_file = False
        # Name the output file.
        if options_and_args.language == 'py':
            out_ext = ".py"
        else:
            out_ext = ".pe"
        output_script = splitext(xgf_file)[0] + out_ext
        # Merge in XIncludes, if we have to, and save the result in a temp file.
        if need_xinclude and \
                (options_and_args.validate or (not processor in
                [LxmlProcessor, LibxsltProcessor, XsltprocProcessor])):
            xgf_file = xinclude_temp_file(xgf_file,
                                          tfile=options_and_args.temp_file)
            delete_temp_file = (options_and_args.temp_file == None)
            diagnostic_message("xgf_file is " + xgf_file)
            diagnostic_message("delete_temp_file is " + str(delete_temp_file))
            need_xinclude = False
            diagnostic_message("Using temp file " + xgf_file)
        # Validate if we haven't been told not to.
        if options_and_args.validate:
            try:
                validator(config, xgf_file, need_xinclude).validate()
            except XGFValidationError as d:
                stderr.write(str(d) + "\n")
                error_free = False
            except Exception as d:
                stderr.write(str(d) + "\n")
                error_free = False
            else:
                diagnostic_message("valid")
        # If no errors so far, go on and compile.
        if error_free and not options_and_args.skip_compilation:
            # Use the script file name supplied by user.
            if options_and_args.output_script is not None:
                output_script = options_and_args.output_script
            try:
                ffscript = processor(config,
                                     xgf_file,
                                     abspath(join(XSLT_DIR, xsl_file)),
                                     options_and_args.params,
                                     need_xinclude).run()
            except XGFCompilationError as d:
                stderr.write(str(d) + "\n")
                error_free = False
            except Exception as d:
                stderr.write(str(d) + "\n")
            else:
                if options_and_args.execute:
                    xgf_prog = Popen(['python', '-'], stdin=PIPE)
                    xgf_prog.communicate(ffscript)
                    if xgf_prog.returncode != 0:
                        stderr.write("Error executing Xgridfit-generated script\n")
                else:
                    f = open(output_script, 'w')
                    f.write(ffscript)
                    f.close()
        # A little fussy, but it calms my nerves.
        if delete_temp_file and original_xgf_file != xgf_file:
            diagnostic_message("removing " + xgf_file)
            remove(xgf_file)
        # If error, don't go on to next file.
        if not error_free:
            break
    if options_and_args.elapsed_time:
        print "Elapsed time:", time() - start_time
    return error_free

def run_config(xgfdir="/usr/local/share/xml/xgridfit/"):
    XGRIDFIT_DIR = abspath(xgfdir)
    """ Creates/reads/updates a configuration file. """
    # Parse the command line
    options_and_args = ConfigOptions()
    # Read the configuration file
    config = Configuration(config_file=options_and_args.config_file,
                           write_access_needed=not options_and_args.show_config)
    # Show the current configuration and exit
    if options_and_args.show_config:
        config.show_current_config()
        exit(0)
    # We will revise only one of these: processors, validators,
    # xgridfit_dir
    current_list = None
    if options_and_args.processors:
        current_list = config.processor_priority
    if options_and_args.validators:
        current_list = config.validator_priority
    # If we have a list, edit it in place
    if current_list is not None:
        config.parse_priority_list(options_and_args.args, current_list)
    if options_and_args.xgridfit_dir:
        XGRIDFIT_DIR = options_and_args.args[0]
    # Save the new configuration file
    try:
        config.save_file()
    except Exception as d:
        stderr.write(str(d))
        return False
    return True

def run_ttx2xgf(xgfdir="/usr/local/share/xml/xgridfit/"):
    XGRIDFIT_DIR = abspath(xgfdir)
    """ Extract TT instructions from a TTX file. """
    start_time = time()
    libxml2.keepBlanksDefault(0)
    # Parse the command line
    options_and_args = TTXOptions()
    # Read the configuration file
    config = Configuration(config_file=options_and_args.config_file,
                           write_access_needed=False)
    config.adjust_configuration(options_and_args)
    # Anything to do?
    if len(options_and_args.args) < 1:
        stderr.write("\n\nError: No TTX file specified!\n\n")
        options_and_args.opt_pars.print_help()
        exit(1)
    else:
        # Do some automatic naming if necessary
        ttx_file = options_and_args.args[0]
        if not ttx_file.endswith((".TTX", ".ttx"), 1):
            ttx_file += ".ttx"
        if len(options_and_args.args) > 1:
            xgf_file = options_and_args.args[1]
        else:
            xgf_file = splitext(ttx_file)[0] + ".xgf"
    diagnostic_message("TTX file is " + ttx_file)
    diagnostic_message("XGF file is " + xgf_file)
    # Find a processor to use.
    processor = findProcessor(config)
    if processor is None:
        stderr.write(NO_PROCESSOR_ERROR)
        exit(1)
    error_free = True
    # Do the transformation.
    try:
        xgf_output = processor(config,
                               ttx_file,
                               abspath(join(UTIL_DIR, "convert-ttx.xsl")),
                               {}, False).run()
    except XGFCompilationError as d:
        stderr.write(str(d) + "\n")
        error_free = False
    except Exception as d:
        stderr.write(str(d) + "\n")
        error_free = False
    if error_free:
        # The instructions are still raw. We need to convert them to XGF
        # command and push elements. If we've gotten this far there's not
        # whole lot that can go wrong, so cover it with one big try block.
        try:
            # Get the output as a libxml2 doc.
            xgf_intermediate_doc = libxml2.parseDoc(xgf_output)
            # Free up some memory.
            del xgf_output
            xgf_root = xgf_intermediate_doc.getRootElement()
            # Get a list of all the glyph programs.
            glyph_list = xgf_root.xpathEval("*[local-name() = 'glyph']")
            # Convert raw instructions to Xgridfit command and push elements.
            for g in glyph_list:
                iset = InstructionSet(g.content)
                for c in g.get_children():
                    c.unlinkNode()
                    c.freeNode()
                iset.parse_and_install(g)
            # Do the same for legacy-functions and pre-program elements.
            tmp_elem_list = xgf_root.xpathEval("*[local-name() = 'legacy-functions']")
            if len(tmp_elem_list) > 0:
                tmp_elem = tmp_elem_list[0]
                iset = InstructionSet(tmp_elem.content)
                for c in tmp_elem.get_children():
                    c.unlinkNode()
                    c.freeNode()
                iset.parse_and_install(tmp_elem)
            tmp_elem_list = xgf_root.xpathEval("*[local-name() = 'pre-program']")
            if len(tmp_elem_list) > 0:
                tmp_elem = tmp_elem_list[0]
                iset = InstructionSet(tmp_elem.content)
                for c in tmp_elem.get_children():
                    c.unlinkNode()
                    c.freeNode()
                iset.parse_and_install(tmp_elem)
            # Save the file and free the memory.
            xgf_intermediate_doc.saveFormatFile(xgf_file, 1)
            xgf_intermediate_doc.freeDoc()
        except Exception as d:
            stderr.write(str(d) + "\n")
            error_free = False
    if options_and_args.elapsed_time:
        print "Elapsed time:", time() - start_time
    return error_free

def run_xgfmerge(xgfdir="/usr/local/share/xml/xgridfit/"):
    XGRIDFIT_DIR = abspath(xgfdir)
    start_time = time()
    # Parse the command line
    options_and_args = MergeOptions()
    # Read the configuration file
    config = Configuration(config_file=options_and_args.config_file,
                           write_access_needed=False)
    config.adjust_configuration(options_and_args)
