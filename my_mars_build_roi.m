 function o = my_mars_build_roi(roitype,inputinfo)
% adjusted from mars_build_roi. Doesn't use GUI
% roi types must be: {'image','voxel', 'sphere', 'box_cw', 'box_lims'}
%input info if whatever you need for the functions, its a cell array
% IMAGE
% inputinfo = {bi, funcs}
%   bi = binary [1 - yes, 0 - no]
%   funcs = string function
% SPHERE
% inputinfo = {c,r}
%   c = Centre of sphere -> 1,2,3 not a string
%   r = Sphere radius
% VOXEL
% inputinfo = {XYZ, mmvox, thespace}
%   XYZ = coordinates ->  1,2,3 not a string
%   mmvox = 'mm' or 'vox'
%   thespace = 'spacebase', or 'image' #spacebase is the default
% BOX_CW
%   inputinfo = {c, w}
%   c = Center of box
%   w = width of box
% POINTS
% inputinfo = {XYZ, mmvox, thespace}
%   XYZ = coordinates ->  1,2,3 not a string
%   mmvox = 'mm' or 'vox'
%   thespace = 'spacebase', or 'image' #spacebase is the default


o = [];  
img_flt = {'image'};

d = [];
switch roitype
    case 'image'
        bi = inputinfo{1};
        funcs = inputinfo{2};
        imgname = spm_get(1, img_flt, 'Image defining ROI');
        [p f e] = fileparts(imgname);
%         binf = spm_input('Maintain as binary image', '+1','b',...
%                      ['Yes|No'], [1 0],1);
        binf = bi;
        if numel(funcs)> 0
            func = funcs;
        else 
            func = '';
        end
%         if spm_input('Apply function to image', '+1','b',...
%                      ['Yes|No'], [1 0],1);
%             spm_input('img < 30',1,'d','Example function:');
%             func = spm_input('Function to apply to image', '+1', 's', 'img');
        %end
        d = f; l = f;
        if ~isempty(func)
            d = [d ' func: ' func];
            l = [l '_f_' func];
        end
        if binf
            d = [d ' - binarized'];
            l = [l '_bin'];
        end
        o = maroi_image(struct('vol', spm_vol(imgname), 'binarize',binf,...
	           'func', func));
	
	% convert to matrix format to avoid delicacies of image format
    o = maroi_matrix(o);
	 
    case 'voxel'
        XYZ = inputinfo{1};
        v = inputinfo{2};
        spo = inputinfo{3};
        not_donef = 1;
        while not_donef
            %XYZ = spm_input('Coordinate(s)', '+1', 'e', []);
            if size(XYZ,1) == 1, XYZ = XYZ'; end
            if size(XYZ,1) ~= 3 && size(XYZ,2) ~= 3 , warning('Need 3xN or Nx3 matrix');
            else XYZ = XYZ'; not_donef = 0;
            end
        end
            %v = char(spm_input('Coordinate(s) in','+1','b','mm|voxels',{'mm','vox'}, 1));
            spopts = {'spacebase','image'};
            splabs =  {'Base space for ROIs','From image'};
%             spo  = spm_input('Space for voxel ROI', '+1', 'm',splabs,...
%                      spopts, 1);
        switch char(spo)
            case 'spacebase'
                sp = maroi('classdata', 'spacebase');
            case 'image'
                img = spm_get([0 1], img_flt, 'Image defining space');
                if isempty(img),return,end
                sp = mars_space(img);
        end
        o = maroi_pointlist(struct('XYZ', XYZ, 'mat', sp.mat), v);
%         if size(XYZ, 2) > 1
%             pos = c_o_m(o); coord_lbl = 'C.o.M.';
%         else
            pos = XYZ; coord_lbl = 'coordinate';
%         end
        d = sprintf('points; %s (%s) [%0.1f %0.1f %0.1f]',coord_lbl,v,pos);
        l = sprintf('points_%s_%s_%0.0f_%0.0f_%0.0f',coord_lbl,v,pos);
    case 'sphere'
        c = inputinfo{1};
        r = inputinfo{2};
%         c = spm_input('Centre of sphere (mm)', '+1', 'e', [], 3); 
%         r = spm_input('Sphere radius (mm)', '+1', 'r', 10, 1);
        d = sprintf('%0.1fmm radius sphere at [%0.1f %0.1f %0.1f]',r,c);
        l = sprintf('sphere_%0.0f-%0.0f_%0.0f_%0.0f',r,c);
        o = maroi_sphere(struct('centre',c,'radius',r));
    case 'box_cw'
        c = inputinfo{1};
        w = inputinfo{2};
%         c = spm_input('Centre of box (mm)', '+1', 'e', [], 3); 
%         w = spm_input('Widths in XYZ (mm)', '+1', 'e', [], 3);
        d = sprintf('[%0.1f %0.1f %0.1f] box at [%0.1f %0.1f %0.1f]',w,c);
        l = sprintf('box_w-%0.0f_%0.0f_%0.0f-%0.0f_%0.0f_%0.0f',w,c);
        o = maroi_box(struct('centre',c,'widths',w));
%     case 'box_lims'
%         X = 
%         X = sort(spm_input('Range in X (mm)', '+1', 'e', [], 2)); 
%         Y = sort(spm_input('Range in Y (mm)', '+1', 'e', [], 2)); 
%         Z = sort(spm_input('Range in Z (mm)', '+1', 'e', [], 2));
%         A = [X Y Z];
%         c = mean(A);
%         w = diff(A);
%         d = sprintf('box at %0.1f>X<%0.1f %0.1f>Y<%0.1f %0.1f>Z<%0.1f',A);
%         l = sprintf('box_x_%0.0f:%0.0f_y_%0.0f:%0.0f_z_%0.0f:%0.0f',A);
%         o = maroi_box(struct('centre',c,'widths',w));
    case 'quit'
        o = [];
        return
        otherwise
        error(['Strange ROI type: ' roitype]);
end
o = descrip(o,d);
o = label(o,l);