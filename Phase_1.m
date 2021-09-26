

close all; clear all;clc; 

%Assume number of bits for transmission is 1024 bit length
bit_len = 1024;
%Generate binary digit with 1024 bit length (1 or 0) 
bin_data = round(rand(1,bit_len));
%Generate 1024 data with  +/- 1 for tranmission signal
signal = generate_signal(bin_data);

%SNR(in dB)=10log(signal power/noise power) , assume signal power is 1
signal_power = 1;
%Generate rate SNR 0-10dB ,step size of 1,EbN0_dB 
SNR_dB = 0:1:20; 
%Convert SNR(in dB) to Decimal ,SNR = 10^(SNR(dB)/10), EbN0
SNR = 10.^(SNR_dB/10); % SNR range from 1..100 real num(For 0..20 SNRdb)
%Theoretical BER , erfc()- complimentary error function
theory_BER = 1/2.*erfc(sqrt(SNR));  

%Set 20 samples(run time for transmission) to run the calculation for SNR
sample_size = 20;
%Interate through different SNR value
for i=1 : length(SNR)
    sum_error = 0;
    for j = 1 : sample_size
    %Generate equal number of noise samples with require noise power
    noise_powers = signal_power ./SNR;
    noise = generate_noise(bit_len,noise_powers(i));
    %Received signal from adding signal with noise
    receive_signal = signal + noise;
    
    %Fix threshold value as 0  
    threshold = 0;
    error =0;
    %Init zeros to store 0 or 1 value from Threshold logic
    output_signal = zeros(1,bit_len);
    
    %Threshold Logic at receiver
    % receive signal >= threshold , output signal treat as 1 
    % receive signal < threshold , output signal treat as 0
    % Compare output value from threshold with input binary data(1/0)
    for k = 1 : bit_len
        if(receive_signal(k)>=threshold)
            output_signal(k) = 1;
        end
        if(receive_signal(k)<threshold)
            output_signal(k) = 0;
        end
        if(receive_signal(k)>=threshold && bin_data(k)==0) || (receive_signal(k)<threshold && bin_data(k)==1)
            error = error + 1;
        end   
    end
    %Compute BER = #no of error during tx/#no of bits during tx 
    error = error ./bit_len;
    %Compute sum of error during transmission 
    sum_error = error + sum_error;
    end
    %Average Error after transmission
    error_rate(i) = sum_error/sample_size; 
end

%============PLOT==============%
figure(1);
semilogy (SNR_dB,error_rate,'r*');
xlabel('Normalized SNR(Eb/N0)')
ylabel('Probability Error(Pe)');
title('BER V.S SNR');
hold on
semilogy (SNR_dB,theory_BER,'m');
legend('Simulation','Theoretical');
axis([0 20 10^(-5) 1]);
hold off

%Data generation
figure(2);
subplot(411);plot(signal);title('Data Generated');
%Noise generation
subplot(412);plot(noise);title('Noise Generated');

%Recieved data generation
subplot(413);plot(receive_signal);title('Recieved Data');
%Output data generation
subplot(414);plot(output_signal);title('Output Data');

function gen_signal = generate_signal(bin_data)
    %Convert to +/- 1 , bin 1 -> +1 , bin 0 -> -1
    gen_signal = 2.* bin_data -1;
end

function gen_noise = generate_noise(bit_len,noise_power)
    %Generate noise w/normal distribution with zero mean and unit variance 
    gen_noise = sqrt(noise_power/2) .* randn(1,bit_len);
end





    



