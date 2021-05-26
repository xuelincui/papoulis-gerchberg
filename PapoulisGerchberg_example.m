clear all 
close all
clc

fid = fopen('signal.bin', 'rb');
x = fread(fid, 'double');

N = length(x);
K = ceil(N/6); % number of the signal to retain: 2M pts

sample_rate = 0.7;
mask = rand(N,1) > (1-sample_rate);

%% papoulis-gerchberg algo
y = x .* mask;      % undersample signal
idx = find(mask);   % sampled value
rec = y; 
figure; plot(x);  hold on

tol = 0.1; err = [10]; niter = 1; derr = 1;
while err(niter) > tol && derr >1e-5
    % thresholding
    REC = fft(rec);
    REC(K+1:N-K) = 0;
    rec = real(ifft(REC)); hp = plot(rec, 'r*');  
    legend('original','recon');drawnow;
    
    % reset samples    
    rec(idx) = y(idx);
    
    % err
    err = [err norm(rec - x)];    
    
    disp(['iteration: ' num2str(niter) '; error: ' num2str(err(niter))])
    
    if (niter < 10)
        pause(0.2)
    else
        pause(0.1)
    end
    
    delete(hp)
    
    niter = niter + 1;
    
    derr = abs(err(niter)-err(niter-1));
end
plot(rec, 'r*');  title('signal recon');
legend('original','recon');
err = err(2:end);

figure
plot(err, '-o');title('error');xlabel('num of iteration')