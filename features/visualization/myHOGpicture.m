function im = myHOGpicture(w, bsx, bsy )
    % myHOGpicture(w, bsx, bxy )
    % Make picture of positive HOG weights.

    % construct a "glyph" for each orientaion
    bim1 = zeros(bsy, bsx);
    bim1(:,round(bsx/2):round(bsx/2)+1) = 1;
    no   = 9;
    bim  = zeros([size(bim1) no]);
    bim(:,:,1) = bim1;
    for i = 2:no,
      bim(:,:,i) = imrotate(bim1, -(i-1)*(180/no), 'crop');
    end

    % make pictures of positive weights bs adding up weighted glyphs
    s = size(w);    
    w(w < 0) = 0;    
    im = zeros(bsy*s(1), bsx*s(2));
    for i = 1:s(1),
      iis = (i-1)*bsy+1:i*bsy;
      for j = 1:s(2),
        jjs = (j-1)*bsx+1:j*bsx;          
        for k = 1:no,
          im(iis,jjs) = im(iis,jjs) + bim(:,:,k) * w(i,j,k);
        end
      end
    end
end