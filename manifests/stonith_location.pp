#
define pacemaker::stonith_location (
    $ensure,
    $resource,
    $score,
) {
    create_resources('pcmk_location', {
        "${name}-${hostname}"   => {# {{{
            'ensure'    => $ensure,
            'resource'  => $resource,
            'node'      => $hostname,
            'score'     => $score,
        }# }}}
    })
}
