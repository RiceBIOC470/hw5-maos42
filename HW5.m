%HW5
%GB comments:
1a 70 question asks to output a file in the repository of the mask image. No image provided.
1b 100
1c 70 same issue as 1a
1d 100
2yeast: 100
2worm: 95 the major concern is the fact that there is a mask framing the image that will be treated equally to the worm masks.
2bacteria: 100
2phase: 100 
Overall: 92


% Note. You can use the code readIlastikFile.m provided in the repository to read the output from
% ilastik into MATLAB.

%% Problem 1. Starting with Ilastik

% Part 1. Use Ilastik to perform a segmentation of the image stemcells.tif
% in this folder. Be conservative about what you call background - i.e.
% don't mark something as background unless you are sure it is background.
% Output your mask into your repository. What is the main problem with your segmentation?  


%It's very difficult to separate cells from background because there are
%several cells very close to each other.


% Part 2. Read you segmentation mask from Part 1 into MATLAB and use
% whatever methods you can to try to improve it. 

seg1=readIlastikFile('stemcells_Simple Segmentation.h5');
figure (1); imshow(seg1);

iseg1=imerode(seg1,strel('disk',2));
iseg1=imdilate(iseg1,strel('disk',2));
figure (2); imshow(iseg1);

cc=bwconncomp(iseg1);
stats=regionprops(cc, 'Area');
area=[stats.Area];
fusedcand=area>mean(area)+std(area);
sublist=cc.PixelIdxList(fusedcand);
sublist=cat(1,sublist{:});
fusedMask=false(size(iseg1));
fusedMask(sublist)=1;
s=round(1.2*sqrt(mean(area))/pi);
nucmin=imerode(fusedMask,strel('disk',s));
outside=~imdilate(fusedMask,strel('disk',3));
basin=imcomplement(bwdist(outside));
basin=imimposemin(basin, nucmin | outside);
%pcolor(basin); shading flat;
L=watershed(basin);
newmask=L>1 | (iseg1-fusedMask);
figure(3); imshow(newmask);


% Part 3. Redo part 1 but now be more aggresive in defining the background.
% Try your best to use ilastik to separate cells that are touching. Output
% the resulting mask into the repository. What is the problem now?

%Many cells are lost due the aggressive input of marking the background,
%and the further you go, the thiner the other cells become, turning into
%almost noise. And also, the biggest problem is that many of these cells
%now have holes. 

% Part 4. Read your mask from Part 3 into MATLAB and try to improve
% it as best you can.

seg4=readIlastikFile('stemcells_Simple Segmentation3.h5');
figure (4); imshow(seg4);

%cc=bwconncomp(seg4);
stats4=regionprops(seg4, 'Area','PixelIdxList');
area4=[stats4.Area];
imgfalse=false(size(seg4));
areas=mean(area4); std4=std(area4);
ids=find(area4>areas/2);
lids=length(ids);

for ii=1:lids
imgfalse(stats4(ids(ii)).PixelIdxList)=true;
end
newimg=imdilate(imgfalse,strel('disk',3));
figure(5); imshow(newimg,[]); %this one is way better than the one from p2


%% Problem 2. Segmentation problems.

% The folder segmentationData has 4 very different images. Use
% whatever tools you like to try to segement the objects the best you can. Put your code and
% output masks in the repository. If you use Ilastik as an intermediate
% step put the output from ilastik in your repository as well as an .h5
% file. Put code here that will allow for viewing of each image together
% with your final segmentation. 

%bacteria=readIlastikFile('bacteria_Simple Segmentation.h5'); 
%your function wouldn't work, and don't know why, but I just read the file from h5read

bacteria=h5read('bacteria_Simple Segmentation.h5', '/exported_data');
fbacteria=squeeze(bacteria==1);
fbac=imdilate(fbacteria,strel('disk',2));
figure (6); imshowpair(imread('bacteria.tif'),fbac');

cellphasec=h5read('cellPhaseContrast_Simple Segmentation.h5', '/exported_data');
fcpc=squeeze(cellphasec==1);
fcpc=imdilate(fcpc,strel('disk',2));
figure (7); imshowpair(imread('cellPhaseContrast.png'),fcpc');

worms=h5read('worms_Simple Segmentation.h5', '/exported_data');
fworms=squeeze(worms==1);
fworms=imdilate(fworms,strel('disk',1));
figure(8); imshowpair(imread('worms.tif'),fworms');

yeast=h5read('yeast_Simple Segmentation.h5', '/exported_data');
fyeast=squeeze(yeast==1);
fyeast=imdilate(fyeast,strel('disk',3));
figure(9); imshowpair(imread('yeast.tif'),fyeast');




