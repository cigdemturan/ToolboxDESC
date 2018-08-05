function [LPQdesc, freqRespAll] = descriptor_LPQ(img,winSize,decorr,freqestim,mode)
% Funtion LPQdesc=lpq(img,winSize,decorr,freqestim,mode) computes the Local Phase Quantization (LPQ) descriptor
% for the input image img. Descriptors are calculated using only valid pixels i.e. size(img)-(winSize-1).
%
% Inputs: (All empty or undefined inputs will be set to default values)
% img = N*N uint8 or double, format gray scale image to be analyzed.
% winSize = 1*1 double, size of the local window. winSize must be odd number and greater or equal to 3 (default winSize=3).
% decorr = 1*1 double, indicates whether decorrelation is used or not. Possible values are:
%                      0 -> no decorrelation, 
%            (default) 1 -> decorrelation
% freqestim = 1*1 double, indicates which method is used for local frequency estimation. Possible values are:
%               (default) 1 -> STFT with uniform window (corresponds to basic version of LPQ)
%                         2 -> STFT with Gaussian window (equals also to Gaussian quadrature filter pair)
%                         3 -> Gaussian derivative quadrature filter pair.
% mode = 1*n char, defines the desired output type. Possible choices are:
%        (default) 'nh' -> normalized histogram of LPQ codewords (1*256 double vector, for which sum(result)==1)
%                  'h'  -> un-normalized histogram of LPQ codewords (1*256 double vector)
%                  'im' -> LPQ codeword image ([size(img,1)-r,size(img,2)-r] double matrix)
%
% Output:
% LPQdesc = 1*256 double or size(img)-(winSize-1) uint8, LPQ descriptors histogram or LPQ code image (see "mode" above)
%
% Example usage:
% img=imread('cameraman.tif');
% LPQhist = lpq(img,3);
% figure; bar(LPQhist);
%

% Version published in 2010 by Janne Heikkilä, Esa Rahtu, and Ville Ojansivu 
% Machine Vision Group, University of Oulu, Finland


%% Defaul parameters
% Local window size
if nargin<2 || isempty(winSize)
    winSize=5; % default window size 3
end

% Decorrelation
if nargin<3 || isempty(decorr)   
    decorr=1; % use decorrelation by default
end
rho=0.90; % Use correlation coefficient rho=0.9 as default

% Local frequency estimation (Frequency points used [alpha,0], [0,alpha], [alpha,alpha], and [alpha,-alpha]) 
if nargin<4 || isempty(freqestim)
    freqestim=1; %use Short-Term Fourier Transform (STFT) with uniform window by default
end
STFTalpha=1/winSize;  % alpha in STFT approaches (for Gaussian derivative alpha=1) 
sigmaS=(winSize-1)/4; % Sigma for STFT Gaussian window (applied if freqestim==2)
sigmaA=8/(winSize-1); % Sigma for Gaussian derivative quadrature filters (applied if freqestim==3)

% Output mode
if nargin<5 || isempty(mode)
    mode='im'; % return normalized histogram as default
end

% Other
convmode='valid'; % Compute descriptor responses only on part that have full neigborhood. Use 'same' if all pixels are included (extrapolates image with zeros).


%% Check inputs
if size(img,3)~=1
    error('Only gray scale image can be used as input');
end
if winSize<3 || rem(winSize,2)~=1
   error('Window size winSize must be odd number and greater than equal to 3');
end
if sum(decorr==[0 1])==0
    error('decorr parameter must be set to 0->no decorrelation or 1->decorrelation. See help for details.');
end
if sum(freqestim==[1 2 3])==0
    error('freqestim parameter must be 1, 2, or 3. See help for details.');
end
if sum(strcmp(mode,{'nh','h','im'}))==0
    error('mode must be nh, h, or im. See help for details.');
end


%% Initialize
img=double(img); % Convert image to double
r=(winSize-1)/2; % Get radius from window size
x=-r:r; % Form spatial coordinates in window
u=1:r; % Form coordinates of positive half of the Frequency domain (Needed for Gaussian derivative)

%% Form 1-D filters
if freqestim==1 % STFT uniform window
    % Basic STFT filters
    w0=(x*0+1);
    w1=exp(complex(0,-2*pi*x*STFTalpha));
    w2=conj(w1);
    
elseif freqestim==2 % STFT Gaussian window (equals to Gaussian quadrature filter pair)
    % Basic STFT filters
    w0=(x*0+1);
    w1=exp(complex(0,-2*pi*x*STFTalpha)); 
    w2=conj(w1);

    % Gaussian window
    gs=exp(-0.5*(x./sigmaS).^2)./(sqrt(2*pi).*sigmaS);
    
    % Windowed filters
    w0=gs.*w0;
    w1=gs.*w1;
    w2=gs.*w2;
    
    % Normalize to zero mean 
    w1=w1-mean(w1);
    w2=w2-mean(w2);
    
elseif freqestim==3 % Gaussian derivative quadrature filter pair
    % Frequency domain definition of filters
    G0=exp(-x.^2*(sqrt(2)*sigmaA)^2);
    G1=[zeros(1,length(u)),0,u.*exp(-u.^2*sigmaA^2)];
    
    % Normalize to avoid small numerical values (do not change the phase response we use)
    G0=G0/max(abs(G0));   
    G1=G1/max(abs(G1));
    
    % Compute spatial domain correspondences of the filters
    w0=real(fftshift(ifft(ifftshift(G0))));
    w1=fftshift(ifft(ifftshift(G1)));
    w2=conj(w1);
    
    % Normalize to avoid small numerical values (do not change the phase response we use) 
    w0=w0/max(abs([real(max(w0)),imag(max(w0))]));
    w1=w1/max(abs([real(max(w1)),imag(max(w1))]));
    w2=w2/max(abs([real(max(w2)),imag(max(w2))]));
end


%% Run filters to compute the frequency response in the four points. Store real and imaginary parts separately
% Run first filter
filterResp=conv2(conv2(img,w0.',convmode),w1,convmode);
% Initilize frequency domain matrix for four frequency coordinates (real and imaginary parts for each frequency).
freqResp=zeros(size(filterResp,1),size(filterResp,2),8); 
% Store filter outputs
freqResp(:,:,1)=real(filterResp);
freqResp(:,:,2)=imag(filterResp);
% Repeat the procedure for other frequencies
filterResp=conv2(conv2(img,w1.',convmode),w0,convmode);
freqResp(:,:,3)=real(filterResp);
freqResp(:,:,4)=imag(filterResp);
filterResp=conv2(conv2(img,w1.',convmode),w1,convmode);
freqResp(:,:,5)=real(filterResp);
freqResp(:,:,6)=imag(filterResp);
filterResp=conv2(conv2(img,w1.',convmode),w2,convmode);
freqResp(:,:,7)=real(filterResp);
freqResp(:,:,8)=imag(filterResp);
% freqRespAll = freqResp;
freqRespAll = filterResp;
% Read the size of frequency matrix
[freqRow,freqCol,freqNum]=size(freqResp);

%% If decorrelation is used, compute covariance matrix and corresponding whitening transform
if decorr == 1
    % Compute covariance matrix (covariance between pixel positions x_i and x_j is rho^||x_i-x_j||)
    [xp,yp]=meshgrid(1:winSize,1:winSize);
    pp=[xp(:) yp(:)];
    dd=dist(pp,pp');
    C=rho.^dd;
    
    % Form 2-D filters q1, q2, q3, q4 and corresponding 2-D matrix operator M (separating real and imaginary parts)
    q1=w0.'*w1;
    q2=w1.'*w0;
    q3=w1.'*w1;
    q4=w1.'*w2;
    u1=real(q1); u2=imag(q1);
    u3=real(q2); u4=imag(q2);
    u5=real(q3); u6=imag(q3);
    u7=real(q4); u8=imag(q4);
    M=[u1(:)';u2(:)';u3(:)';u4(:)';u5(:)';u6(:)';u7(:)';u8(:)'];
    
    % Compute whitening transformation matrix V
    D=M*C*M';
    A=diag([1.000007 1.000006 1.000005 1.000004 1.000003 1.000002 1.000001 1]); % Use "random" (almost unit) diagonal matrix to avoid multiple eigenvalues.  
    [U,S,V]=svd(A*D*A);
   
    % In order to avoid any sign problems in SVM, force the sign of the largest magnitude element in each singular vector to be positive
    [~,ii]=max(abs(V),[],1);
    V=V*diag(ones(1,size(V,2))-2*double(V((ii+(0:(length(ii)-1))*size(V,1)))<(-eps)));

    % Reshape frequency response
    freqResp=reshape(freqResp,[freqRow*freqCol,freqNum]);

    % Perform whitening transform
    freqResp=(V.'*freqResp.').';
    
    % Undo reshape
    freqResp=reshape(freqResp,[freqRow,freqCol,freqNum]);
end


%% Perform quantization and compute LPQ codewords
LPQdesc=zeros(freqRow,freqCol); % Initialize LPQ code word image (size depends whether valid or same area is used)
for i=1:freqNum
    LPQdesc=LPQdesc+(double(freqResp(:,:,i))>0)*(2^(i-1));
end

%% Switch format to uint8 if LPQ code image is required as output
if strcmp(mode,'im')
    LPQdesc=uint8(LPQdesc);
end

%% Histogram if needed
if strcmp(mode,'nh') || strcmp(mode,'h')
    LPQdesc=hist(LPQdesc(:),0:255);
end

%% Normalize histogram if needed
if strcmp(mode,'nh')
    LPQdesc=LPQdesc/sum(LPQdesc);
end




