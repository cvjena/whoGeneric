% function [R,neg] = whitenWithDropout(bg,lda,nx,ny)
% Obtain whitenixng matrix and mean from a general HOG model   
% by a cholesky decompoition on a stationairy covariance matrix 
% feat' = R\(feat - neg) has zero mean and unit covariance
%
% bg.neg: negative mean (nf by 1)
% bg.cov: covariance for k spatial offsets (nf by nf by k)
% bg.dxy: k spatial offsets (k by 2)
% lda.lambda: regularizer
function [R,neg,b_success] = whitenWithDropout(bg,lda,nx,ny)

    if ( nargout > 2 )
        b_success = true;
    end
  
%     % the following line is intended to prevent memory overwhelming due to
%     % impossibly large covariance matrices which could be desired for large
%     % selected regions...
%     %
%     % size(bg.cov,1) -> number of feature dimensions
%     % nx -> size of desired filter x dimension
%     % ny -> size of desired filter y dimension
%     %
%     if ( ((nx*ny)^2 * size(bg.cov,1)^2 )> 5*10e8 )
%         if ( nargout > 2 )
%             R         = [];
%             neg       = [];
%             b_success = false;
%             return;
%         end        
%     end

    % now start the actual whitening
    neg = repmat(bg.neg',ny*nx,1);
    neg = neg(:);
    p   = 1;
  

  
  
%   if ( ~isfield(lda,'b_noiseDropOut') || isempty(lda.b_noiseDropOut) )
%       b_noiseDropOut = true;
%   else
%       b_noiseDropOut = lda.b_noiseDropOut;
%   end
%   
%   if ( ~isfield(lda,'d_dropOutProb') || isempty(lda.d_dropOutProb) )
%       d_dropOutProb = 0.1;
%   else
%       d_dropOutProb = lda.d_dropOutProb;
%   end
  

  
  while(p~=0)
      [sig, b_success] = reconstructSig(nx,ny,bg.cov,bg.dxy);
      if ( ~b_success)
            R         = [];
            neg       = [];
            if ( nargout > 2 )
                b_success = false;
            end
            return;
      end

      % drop-out like noise model, as described by Chen et al. (Marginalized Denoising Autoencoders for Domain Adaptation)
      if ( lda.b_noiseDropOut )
          d=size(sig,1);
          q=ones(d,1) .* (1-lda.d_dropOutProb);
          sig=sig.*(q*q');
      end

      % Gaussian noise model for every dimension
      sig = sig + lda.lambda*eye(size(sig));  

      [R,p] = chol(sig);
      if p ~= 0,
        %disp('Increasing lambda');
        lda.lambda = lda.lambda*5;
        %display('Sig is not positive definite, add a larger regularizer');
        %keyboard;
      end
  end
end
  
function [w, b_success] = reconstructSig(nx,ny,ww,dxy)
% W = reconstructSig(nx,ny,ww,dxy)
% W = n x n 
% n = ny * nx * nf

  if ( nargout > 1 )
    b_success = true;
  end

  k  = size(dxy,1);
  nf = size(ww,1);
  n  = ny*nx;  
  try
      
      w  = zeros(nf,nf,n,n);

      for x1 = 1:nx,
        for y1 = 1:ny,
          i1 = (x1-1)*ny + y1;
          for i = 1:k,
            x = dxy(i,1);
            y = dxy(i,2);
            x2 = x1 + x;        
            y2 = y1 + y;
            if x2 >= 1 && x2 <= nx && y2 >= 1 && y2 <= ny,
              i2 = (x2-1)*ny + y2;
              w(:,:,i1,i2) = ww(:,:,i); 
            end
            x2 = x1 - x;        
            y2 = y1 - y;
            if x2 >= 1 && x2 <= nx && y2 >= 1 && y2 <= ny,
              i2 = (x2-1)*ny + y2; 
              w(:,:,i1,i2) = ww(:,:,i)'; 
            end
          end
        end
      end

      % Permute [nf nf n n] to [n nf n nf]
      w = permute(w,[3 1 4 2]);
      w = reshape(w,n*nf,n*nf);

      % Make sure returned matrix is close to symmetric
      assert(sum(sum(abs(w - w'))) < 1e-5);

      w = (w+w')/2;
  catch err      
      w = [];
      if ( nargout > 1 )
        b_success = false;
      end
      return;
  end
end