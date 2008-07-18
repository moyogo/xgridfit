/^[ 	]*<asm>$/ d
/^[ 	]*<\/asm>$/ d
s/<asm>//
s/<\/asm>//
s/^[ 	]*$/<*>/
/PUSH[BW]/ d
s/^[ 	]*\([ 0-9\-]*\)$/<push>\1<\/push>/
/<push>[ 	]*<\/push>/ d
s/^<\*>$//
s/^[^A-Z]*\(GC\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(IUP\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(MD\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(MDAP\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(MDRP\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(MIAP\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(MIRP\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(MSIRP\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(NROUND\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(ROUND\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(SDPVTL\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(SFVTCA\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(SFVTL\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(SHC\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(SHP\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(SHZ\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(SPVTCA\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(SPVTL\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z]*\(SVTCA\)\[\(.*\)\].*$/<command name="\1" modifier="\2"\/>/
s/^[^A-Z012]*\([A-Z0123]*\)\[ *\].*$/<command name="\1"\/>/
s/^<command/      <command/
s/^<push/      <push/
