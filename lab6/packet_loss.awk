BEGIN {
	recv = 0;
	gen = 0;
}

$1=="+" && ($3==0 || $3 == 2 || $3 == 3) && $2<now{
	gen++;
};

$1=="r" && $4==toNode && $2<now{
	recv++;
};
END{
packet_loss=gen-recv;
print packet_loss; 
};
