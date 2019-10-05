#!/usr/bin/env python3
"""
Include preprocessor

Usage:
    python3 include.py <file>

Reads in <file> and writes to stdout. Any string 'include <file>' is replaced
with the contents of <file>. Any whitespace before include is preserved and
added to each line of the included file. Included files may include additional files.

"""

import os
import re
import sys
#import python_minifier

def escape(line) -> str:
    """ Escape '<<' that is not part of a parameter expansion with a preceding '\' """

    escaped = ''

    def split(line):
        """
        Split line by parameter expansions

        Yield tuples of (a, param) where a is text that should be escaped and
        param is a parameter expansion which should not.

        >>> list(split('cat >> << parameters.name >>.txt <<EOF'))
        [('cat >> ', '<< parameters.name >>'), ('.txt <<EOF', '')]

        """

        it = iter(re.split(r'((?:<<)\s*parameters\.\S+\s*(?:>>))', line))
        for s in it:
            try:
                yield s, next(it)
            except StopIteration:
                yield s, ''

    for esc, parameter in split(line):
        escaped += esc.replace('<<', '\<<')
        escaped += parameter

    return escaped


def read_file(path: str, pad: str = '') -> None:
    dirname = os.path.dirname(path)

    do_escape = not path.endswith('.yml')

    with open(path, encoding='utf-8') as f:

        #if path.endswith('.py'):
        #    for line in python_minifier.minify(f.read(), rename_locals=False, hoist_literals=False).splitlines():
        #        print(pad + line)
        #    return

        for line in f.readlines():
            match = re.match(r'(\s*)include\s+(.*)', line)
            if match:
                read_file(os.path.join(dirname, match.group(2)), pad + match.group(1))
            else:
                if do_escape:
                    print(pad + escape(line), end='')
                else:
                    print(pad + line, end='')


if __name__ == '__main__':
    read_file(os.path.abspath(sys.argv[1]))
