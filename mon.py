#!/usr/bin/env python

from __future__ import print_function

import os
import sys
import subprocess
import datetime
import time

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

BASEDIR = os.path.abspath(os.path.dirname(__file__))


def now():
    return datetime.datetime.now().strftime("%Y/%m/%d %H:%M:%S")


def build_docs(event):
    print("Building docs at %s" % now(), file=sys.stderr)
    print("-" * 79)
    os.chdir(BASEDIR)
    subprocess.call(r'ldoc.lua src', shell=True)
    print("-" * 79)


def run_tests(event):
    print("Running unit tests at %s" % now(), file=sys.stderr)
    print("-" * 79)
    os.chdir(BASEDIR)
    subprocess.call(r'busted')
    print("-" * 79)


def getext(filename):
    return os.path.splitext(filename)[-1].lower()


class ChangeHandler(FileSystemEventHandler):
    """
    React to changes in Python and Rest files by
    running unit tests (Python) or building docs (.rst)
    """
    def __init__(self, extensions, func):
        if isinstance(extensions, str):
            self.__exts = [extensions]
        else:
            self.__exts = list(extensions)
        self.__func = func

    def on_any_event(self, event):
        if event.is_directory:
            return

        if getext(event.src_path) in self.__exts:
            self.__func(event)


def main():
    while 1:
        test_handler = ChangeHandler('.lua', run_tests)
        docs_handler = ChangeHandler('.lua', build_docs)

        observer = Observer()
        observer.schedule(test_handler, BASEDIR, recursive=True)
        observer.schedule(docs_handler, os.path.join(BASEDIR, 'src'), recursive=True)
        observer.start()

        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            observer.stop()

        observer.join()


if __name__ == '__main__':
    main()
