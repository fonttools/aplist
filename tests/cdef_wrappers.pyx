#cython: language_level=3
#distutils: define_macros=CYTHON_TRACE_NOGIL=1

from aplist._aplist cimport (
    _text,
    ParseInfo,
    line_number_strings as c_line_number_strings,
    is_valid_unquoted_string_char as c_is_valid_unquoted_string_char,
    advance_to_non_space as c_advance_to_non_space,
)
from cpython.unicode cimport (
    PyUnicode_FromUnicode, PyUnicode_AS_UNICODE, PyUnicode_GET_SIZE,
)


cdef class ParseContext:

    cdef unicode s
    cdef ParseInfo pi
    cdef object dict_type

    @classmethod
    def fromstring(ParseContext cls, string, Py_ssize_t offset=0, dict_type=dict):
        cdef ParseContext self = ParseContext.__new__(cls)
        self.s = _text(string)
        cdef Py_ssize_t length = PyUnicode_GET_SIZE(self.s)
        cdef Py_UNICODE* buf = PyUnicode_AS_UNICODE(self.s)
        self.dict_type = dict_type
        self.pi = ParseInfo(
            begin=buf,
            curr=buf + offset,
            end=buf + length,
            dict_type=<void*>dict_type,
        )
        return self


def is_valid_unquoted_string_char(Py_UNICODE c):
    return c_is_valid_unquoted_string_char(c)


def line_number_strings(s, offset=0):
    cdef ParseContext ctx = ParseContext.fromstring(s, offset)
    return c_line_number_strings(&ctx.pi)


def advance_to_non_space(s, offset=0):
    cdef ParseContext ctx = ParseContext.fromstring(s, offset)
    eof = not c_advance_to_non_space(&ctx.pi)
    return None if eof else s[ctx.pi.curr - ctx.pi.begin]
