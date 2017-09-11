BEGIN {
	recv = 0;
	gen = 0;
}

$1=="+" && ($3==0 || $3 == 2 || $3 == 3){
	gen++;
};

$1=="r" && $4=="9" {
	recv++;
};
END{
packet_loss=gen-recv;
printf("%f %f\n",x, packet_loss); 
};
