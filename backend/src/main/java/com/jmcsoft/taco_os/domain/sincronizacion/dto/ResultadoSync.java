package com.jmcsoft.taco_os.domain.sincronizacion;

import java.util.List;

public record ResultadoSync(
        int synced,
        int failed,
        List<String> conflicts,
        String server_time
) {}

