BEGIN {
    bytes_recv = 0;
}

$1 == "r" && $4 == "9" {
    bytes_recv = bytes_recv + $6;
};

END {
    throughput = (bytes_recv)/(5 * 1000000);
    printf("%f %f\n",x, throughput);
};