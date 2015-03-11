/**
    Ceylon PHP Compiler Backend

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.php.ast {
    Name
}
import de.anhnhan.utils {
    pipe2
}

"List of names that are absolute no-go (ok, you can use them as variable names though...)."
{String+} phpKeywords = {
    "class", "interface",
    "extends", "implements",
    "public", "private", "protected",
    "abstract", "final",
    "namespace", "use", "var",
    "function",
    "instanceof", "clone",
    "static", "global", "const",
    "true", "false",
    "and", "or", "xor",
    "if", "else", "elseif",
    "for", "while", "do", "foreach",
    "declare", "goto", "new",
    "endif", "endswitch", "endfor", "endforeach", "endwhile", "enddeclare",
    "break", "continue",
    "switch", "case", "default",
    "try", "catch", "throw",
    "self", "parent"
};

{String+} phpMagicMethods = {
    "__contruct", "__desctruct", "__call", "__callStatic", "__get", "__set",
    "__isset", "__unset", "__sleep", "__wakeup", "__toString", "__invoke",
    "__set_state", "__clone", "__debugInfo"
};

Boolean isPhpPredefinedConstantName(Name|String name)
{
    switch (name)
    case (is Name)
    {
        return name.last.uppercased in phpConstants;
    }
    case (is String)
    {
        return name.uppercased in phpConstants;
    }
}

"These constant names are all root-level names, meaning you can overwrite them
 in a namespaced context. Since these are quite common, we better disallow
 naming things exactly like predefined constants."
{String+} phpConstants = {
    "__CLASS__", "__DIR__", "__FILE__", "__LINE__", "__FUNCTION__", "__METHOD__", "__NAMESPACE__",
    "PHP_VERSION", "PHP_MAJOR_VERSION", "PHP_MINOR_VERSION", "PHP_RELEASE_VERSION", "PHP_VERSION_ID", "PHP_EXTRA_VERSION",
    "PHP_ZTS", "PHP_DEBUG", "PHP_MAXPATHLEN", "PHP_OS", "PHP_SAPI", "PHP_EOL",
    "PHP_INT_MAX", "PHP_INT_SIZE", "DEFAULT_INCLUDE_PATH",
    "PEAR_INSTALL_DIR", "PEAR_EXTENSION_DIR", "PHP_EXTENSION_DIR", "PHP_PREFIX",
    "PHP_BINDIR", "PHP_LIBDIR", "PHP_DATADIR", "PHP_SYSCONFDIR", "PHP_LOCALSTATEDIR",
    "PHP_CONFIG_FILE_PATH", "PHP_CONFIG_FILE_SCAN_DIR", "PHP_SHLIB_SUFFIX",
    "PHP_OUTPUT_HANDLER_START", "PHP_OUTPUT_HANDLER_CONT", "PHP_OUTPUT_HANDLER_END",
    "E_ERROR", "E_WARNING", "E_PARSE", "E_NOTICE", "E_CORE_ERROR", "E_CORE_WARNING",
    "E_COMPILE_ERROR", "E_COMPILE_WARNING", "E_USER_ERROR", "E_USER_WARNING", "E_USER_NOTICE",
    "E_DEPRECATED", "E_USER_DEPRECATED", "E_ALL", "E_STRICT", "__COMPILER_HALT_OFFSET__",
    "TRUE", "FALSE", "NULL",
    // Constants as inputs towards stdlib functions
    "EXTR_OVERWRITE", "EXTR_SKIP", "EXTR_PREFIX_SAME", "EXTR_PREFIX_ALL", "EXTR_PREFIX_INVALID", "EXTR_PREFIX_IF_EXISTS", "EXTR_IF_EXISTS",
    "SORT_ASC", "SORT_DESC", "SORT_REGULAR", "SORT_NUMERIC", "SORT_STRING",
    "CASE_LOWER", "CASE_UPPER", "COUNT_NORMAL", "COUNT_RECURSIVE",
    "ASSERT_ACTIVE", "ASSERT_CALLBACK", "ASSERT_BAIL", "ASSERT_WARNING", "ASSERT_QUIET_EVAL",
    "CONNECTION_ABORTED", "CONNECTION_NORMAL", "CONNECTION_TIMEOUT",
    "INI_USER", "INI_PERDIR", "INI_SYSTEM", "INI_ALL",
    "M_E", "M_LOG2E", "M_LOG10E", "M_LN2", "M_LN10", "M_PI", "M_PI_2", "M_PI_4", "M_1_PI", "M_2_PI", "M_2_SQRTPI", "M_SQRT2", "M_SQRT1_2",
    "CRYPT_SALT_LENGTH", "CRYPT_STD_DES", "CRYPT_EXT_DES", "CRYPT_MD5", "CRYPT_BLOWFISH", "DIRECTORY_SEPARATOR",
    "SEEK_SET", "SEEK_CUR", "SEEK_END", "LOCK_SH", "LOCK_EX", "LOCK_UN", "LOCK_NB",
    "HTML_SPECIALCHARS", "HTML_ENTITIES", "ENT_COMPAT", "ENT_QUOTES", "ENT_NOQUOTES",
    "INFO_GENERAL", "INFO_CREDITS", "INFO_CONFIGURATION", "INFO_MODULES", "INFO_ENVIRONMENT",
    "INFO_VARIABLES", "INFO_LICENSE", "INFO_ALL", "CREDITS_GROUP", "CREDITS_GENERAL",
    "CREDITS_SAPI", "CREDITS_MODULES", "CREDITS_DOCS", "CREDITS_FULLPAGE", "CREDITS_QA", "CREDITS_ALL",
    "STR_PAD_LEFT", "STR_PAD_RIGHT", "STR_PAD_BOTH", "PATHINFO_DIRNAME", "PATHINFO_BASENAME",
    "PATHINFO_EXTENSION", "PATH_SEPARATOR", "CHAR_MAX",
    "LC_CTYPE", "LC_NUMERIC", "LC_TIME", "LC_COLLATE", "LC_MONETARY", "LC_ALL",
    "LC_MESSAGES", "ABDAY_1", "ABDAY_2", "ABDAY_3", "ABDAY_4", "ABDAY_5", "ABDAY_6", "ABDAY_7",
    "DAY_1", "DAY_2", "DAY_3", "DAY_4", "DAY_5", "DAY_6", "DAY_7",
    "ABMON_1", "ABMON_2", "ABMON_3", "ABMON_4", "ABMON_5", "ABMON_6", "ABMON_7", "ABMON_8", "ABMON_9", "ABMON_10", "ABMON_11", "ABMON_12",
    "MON_1", "MON_2", "MON_3", "MON_4", "MON_5", "MON_6", "MON_7", "MON_8", "MON_9", "MON_10", "MON_11", "MON_12",
    "AM_STR", "PM_STR", "D_T_FMT", "D_FMT", "T_FMT", "T_FMT_AMPM", "ERA", "ERA_YEAR", "ERA_D_T_FMT", "ERA_D_FMT", "ERA_T_FMT"
};

"List of names that should not be used for top-level function declarations or
 type names."
{String+} phpLanguageConstructs = {
    "callable", "array", "die", "echo", "empty", "exit", "eval", "isset", "list",
    "return", "print", "unset", "__halt_compiler",
    "include", "include_once",
    "require", "require_once"
};

// Srsly?
"Contains only the names we need to consider in code-generation context."
{Name+} phpBuiltinTypes = [
    "DateTime", "stdClass", "__PHP_Incomplete_Class", "Directory", "Closure", "php_user_filter"
].collect(pipe2(pipe2((String str) => Array { str }, `ArraySequence<String>`), `Name` of Name([String+])));
