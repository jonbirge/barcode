%% Generate code

% test parameters
clearvars
nbytes = 128*1024;
data = uint8(gensawbytes(nbytes));

% encode parameters
codepar.dpi = 98;
codepar.win = 7.5;  % inches
codepar.hin = 10;  % inches
codepar.linepix = 2;  % pixels per barcode frame

% print parameters
printsnr = 8;  % linear scale
pwin = 8.5;
phin = 11;
wbuf = (pwin - codepar.win)/codepar.win;
hbuf = (phin - codepar.hin)/codepar.hin;


%% save simulates scan image files

% remove old
delete('pagecode_*.tif')

% dense pagination
pixperbyte = 4*8/2;  % coding specific
overheadpix = 5*pixperbyte;
pageframes = floor(codepar.dpi*codepar.hin/codepar.linepix);
framebytes = floor((codepar.dpi*codepar.win - overheadpix)/pixperbyte);
nframes = ceil(nbytes/framebytes);
npages = ceil(nframes/pageframes);

% actual even pagination
pagebytes = ceil(nbytes/npages);

parfor kpage = 1:npages
  % encode
  idx1 = (kpage - 1)*pagebytes + 1;
  idx2 = min(idx1 + pagebytes - 1, nbytes);
  pagedata = data(idx1:idx2); %#ok<PFBNS> 
  codim = encodepage(pagedata, codepar);

  % simulate print and scan
  im = simpage(codim, printsnr, hbuf, wbuf);
  imscan = logical(round(im));
  filename = ['pagecode_' num2str(kpage)];
  imwrite(~imscan, [filename '.tif']);
end
