# ezpublish basic command completion

_ezpublish4_get_cache_command_list () {
    php bin/php/ezcache.php --help | sed "1,/Options:/d" | awk '/^  .+/ { print $1 }'
    #php bin/php/ezcache.php --help | sed "1,/Options:/d"
}

_ezpublish4 () {
  if [ -f bin/php/ezcache.php ]; then
    compadd `_ezpublish4_get_cache_command_list`
  fi
}

compdef _ezpublish4 bin/php/ezcache.php

# eZ publish 4 Aliases
if [[ "$(uname -s)" == "Darwin" ]]; then
    APACHEUSER=www
elif [[ "$(uname -s)" == "Linux" ]]; then
    if [[ "lsb_release -si" == "Debian" ]]; then
        APACHEUSER=www-data
    elif [[ "lsb_release -si" == "Rhel" ]]; then
        APACHEUSER=apache                                                                                                                                                                      
    fi  
fi
EZ_CACHE="sudo -u ${APACHEUSER} php bin/php/ezcache.php"
EZ_GEN_AUTO="sudo -u ${APACHEUSER} php bin/php/ezpgenerateautoloads.php"
EZF_INDEX="sudo -u ${APACHEUSER} php extension/ezfind/bin/php/updatesearchindexsolr.php -conc=1 -s"
alias ezcac="${EZ_CACHE} --clear-all"
alias ezcic="${EZ_CACHE} --clear-tag=ini"
alias ezctc="${EZ_CACHE} --clear-tag=template"
alias ezga="${EZ_GEN_AUTO}"
alias ezfidx="${EZF_INDEX}"