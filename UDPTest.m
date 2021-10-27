function UDPTest()
ip = '169.254.171.129';
udps = dsp.UDPSender('RemoteIPPort', 20000, 'RemoteIPAddress', ip);

loop = 1;

while loop == 1
    data = uint8(input('Input data to send (Y for no turn, N for turn)', 's'));
    step(udps, data);
end
   
release(udps);
end