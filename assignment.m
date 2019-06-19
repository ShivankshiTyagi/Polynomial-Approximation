global cc1;
originalimage =imread('/home/sukh28/pic1.jpg');
imshow(originalimage);
binImage=im2bw(originalimage);
cc = bwconncomp(binImage);  %gives number of connected components
curve_lengths = cellfun(@numel,cc.PixelIdxList); % gives length of connected components
length=0;               
ymin=size(binImage,2)+100; 
curve=false(size(binImage));
curve_index=1;
for i=1:cc.NumObjects
  
  if length<curve_lengths(i)
    length=curve_lengths(i);
    props = regionprops(cc, 'PixelList');
    ycurve=min(props(i).PixelList)(2);
    bw2=false(size(binImage));   %Storing longest curve 
    bw2(cc.PixelIdxList{i})=true;  
    
    if ymin>ycurve
      ymin=ycurve;
      curve=bw2;                 %storing nearesr curve 
      curve_index=i;
    end  
    
  end
end
figure,imshow(curve);

no_pixels=size(props(curve_index).PixelList)(1);

for i=1:no_pixels
  x_coordinates(i)=props(curve_index).PixelList(i,1);
  y_coordinates(i)=props(curve_index).PixelList(i,2);
end
m = y_coordinates(no_pixels)-y_coordinates(1)/x_coordinates(no_pixels)-x_coordinates(1)
if y_coordinates(1)>y_coordinates(no_pixels)
  x1 = (1- y_coordinates(no_pixels))/m +x_coordinates(no_pixels)
  hold on 
    line([x_coordinates(no_pixels),x1],[y_coordinates(no_pixels),1],'Color','w','LineWidth',1)
  hold off
else 
  x1 = (1- y_coordinates(1))/m +x_coordinates(1)
  hold on 
    line([x_coordinates(1),x1],[y_coordinates(1),1],'Color','w','LineWidth',1)
  hold off
end
  
%curve end points for initial curve
y_curveend=max(props(curve_index).PixelList)(2);
x_curveend=max(props(curve_index).PixelList)(1);
      for a=1:size(props(curve_index).PixelList,1)
       for b=1:size(props(curve_index).PixelList,2)
         if props(curve_index).PixelList(a,b)==y_curveend
           if x_curveend>props(curve_index).PixelList(a,1)
             x_curveend=props(curve_index).PixelList(a,1);
           end
         end
       endfor
      endfor
%figure,imshow(originalimage);
global A;
global type;
%search area for initial curve
if x_curveend-100>0
  %rectangle('Position',[x_curveend-100,y_curveend+1,200,200],'EdgeColor','r');
  J = imcrop(originalimage,[x_curveend-100,y_curveend+1,200,200]);
  %figure,imshow(J);
  A=[100 1];
  type=1;
else
  %rectangle('Position',[1,y_curveend+1,100+x_curveend,200],'EdgeColor','r');
  J = imcrop(originalimage,[1,y_curveend+1,100+x_curveend,200]);
  %figure,imshow(J);
  A=[x_curveend 1];
  type=2;
end
 
binImage1=im2bw(J);
cc1 = bwconncomp(binImage1);
num=cc1.NumObjects;

function [x_curveendnw,y_curveendnw]=three_functions(originalimage,x_curveend,y_curveend)
  global curve;
  global cc1;
  global A;
  global type;
  global x_coordinates;
  global y_coordinates;
  
  %%Function 1: nearest non-zero pixel from (x_curveend,y_curveend) 
  curve_lengths1 = cellfun(@numel,cc1.PixelIdxList);
  props1 = regionprops(cc1, 'PixelList');
  pmin = 50000000;
  idx=1;
  curve_index2=1;
  for i=1:cc1.NumObjects
    P=props1(i).PixelList;
    [pmin1,idx1] = min(sum(bsxfun(@minus, P,A).^2,2));
    if pmin>pmin1
      pmin = pmin1;
      idx= idx1;
      curve_index2=i;
    end
  end
   %storing the coordinates wrt window
  
  %nearest non-zero pixel cordinates wrt original image
  if type==1
    out= plus(P(idx, :), [x_curveend-100,y_curveend+1]);
  else
    out= plus(P(idx, :), [1,y_curveend+1]);
  end
  
  %%Function 2: calculating the end points of curve wrt window
  y_curveend1=max(props1(curve_index2).PixelList)(2);
  x_curveend1=max(props1(curve_index2).PixelList)(1);
      for a=1:size(props1(curve_index2).PixelList,1)
       for b=1:size(props1(curve_index2).PixelList,2)
         if props1(curve_index2).PixelList(a,b)==y_curveend1
           if x_curveend1>props1(curve_index2).PixelList(a,1)
              x_curveend1=props1(curve_index2).PixelList(a,1);
           end
         end
       end
      end
  
  %final coordinates wrt original image
  num=cc1.NumObjects;
  if type==1
    x_curveendnw=x_curveend1+x_curveend-100;
    y_curveendnw=y_curveend1+y_curveend+1;
  else
    x_curveendnw=x_curveend1+1;
    y_curveendnw=y_curveend1+y_curveend+1;
  end
  
  %%draw straight line between curve end coordinates and nearest curve coordinates
  hold on
    line([x_curveend,out(1)],[y_curveend,out(2)],'Color','w','LineWidth',1)
  hold off
  
  y_coordinates1={};
  x_coordinates1={};
  a=1;
  aa=1;
  for i=props1(curve_index2).PixelList(idx,2):y_curveend1
    y_coordinates1(a)=i;
    for aa=1:size(props1(curve_index2).PixelList,1)
      if props1(curve_index2).PixelList(aa,2)==i
        x_coordinates1(a)=props1(curve_index2).PixelList(aa,1);
      endif
      aa=aa+1;
    endfor
    a=a+1;
  endfor
  y_coordinates1;
  x_coordinates1;
  x_coordinates1=cell2mat(x_coordinates1);
  y_coordinates1=cell2mat(y_coordinates1);
  
  
  %final array of nearest curve coordinates wrt original image
  if type==1
    x_coordinates1=x_coordinates1.+(x_curveend-100);
    y_coordinates1=y_coordinates1.+(y_curveend+1);
  else
    x_coordinates1=x_coordinates1.+1;
    y_coordinates1=y_coordinates1.+(y_curveend+1);
  end
  
  %draw the curve
  %[a,b] = polyfit(x_coordinates1,y_coordinates1,1);
  hold on
    plot(x_coordinates1,y_coordinates1,'w');
  hold off
  
  %%Function 3: rectangle formation and cropping image
  if x_curveendnw-100>0
    %rectangle('Position',[x_curveendnw-100,y_curveendnw+1,200,200],'EdgeColor','r');
    J = imcrop(originalimage,[x_curveendnw-100,y_curveendnw+1,200,200]);
    %figure,imshow(J);
    A=[100 1];
    type=1;
  else
    %rectangle('Position',[1,y_curveendnw+1,100+x_curveendnw,200],'EdgeColor','r');
    J = imcrop(originalimage,[1,y_curveendnw+1,100+x_curveendnw,200]);
    %figure,imshow(J);
    A=[x_curveendnw 1];
    type=2;
  endif
  binImage1=im2bw(J);
  cc1 = bwconncomp(binImage1);
endfunction

while(cc1.NumObjects!=0)
  [x_curveend,y_curveend]=three_functions(originalimage,x_curveend,y_curveend);
endwhile


