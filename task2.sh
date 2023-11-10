#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <output.txt>"
    exit 1
fi

input_file="$1"

awk '
BEGIN {
    print "{";
    success = 0;
    failed = 0;
}

# Извлечение testName
/\[/{
    match($0, /\[(.*)\]/, a);
    gsub(/^[\t ]+|[\t ]+$/, "", a[1]);
    print "  \"testName\": \"" a[1] "\",";
    print "  \"tests\": [";
    next;
}

# Пропуск строк с ---
/-----------------------------------------------------------------------------------/ { sub(/,$/, ""); next; }

# Обработка строк с результатами тестов
{
    # Если строка не содержит "ok", пропустить обработку
    if ($0 !~ /ok/) {
        next;
    }

    match($0, /^([^0-9]*)([0-9]+)(.*),(.*)ms$/, a);
    status = (a[1] ~ /not/) ? "false" : "true";
    if (status == "true") success++;
    else failed++;
    gsub(/^[\t ]+|[\t ]+$/, "", a[3]);
    gsub(/^[\t ]+|[\t ]+$/, "", a[4]);
    line = "    {\n      \"name\": \""a[3] "\",\n      \"status\": "status ",\n      \"duration\": \""a[4] "ms\"\n    }";
    if (prev_line) print prev_line ",";
    prev_line = line;
}

END {
    if (prev_line) print prev_line;
}

# Обработка последней строки с общими результатами
END {
    if (NF > 0) {
        split($0, a, " ");
        last_substring = a[length(a)];
        print "  ],";
        print "  \"summary\": {";
        print "    \"success\": "success",";
        print "    \"failed\": "failed",";
        print "    \"rating\": " ((success / (success + failed)) * 100 == int((success / (success + failed)) * 100) ? int((success / (success + failed)) * 100) : sprintf("%.2f", (success / (success + failed)) * 100)) ",";
        gsub(/[^0-9ms]/, "", a[4]);
        print "    \"duration\": \""last_substring"\"";
        print "  }";
        print " }";
    }
}' output.txt > output.json
echo "Conversion completed. Output written to output.json."
