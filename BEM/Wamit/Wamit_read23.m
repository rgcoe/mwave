%{ 
mwave - A water wave and wave energy converter computation package 
Copyright (C) 2014  Cameron McNatt

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Contributors:
    C. McNatt
%}
function [Forces, T, Beta, Modes] = Wamit_read23(folderpath, runname, rho, g, varargin)
% reads WAMIT .2 output file
% returns the diffraction forces (Forces), the periods (T), the headings 
% (Beta), and the Modes (Modes)
if ~isempty(varargin)
    ext = varargin{1};
    if ~strcmp(ext, 'fk') 
        if ~strcmp(ext, 'sc')
            error(['The additional argument for Wamit_read23 must be either ' ...
                ' ''fk'' or ''sc'' indicating the Froude-Krylov or scattering force should be read']);
        end
    end
else
    ext = '';
end


% read in the file and ignore the header line.
try
    file_data = importdata(fullfile(folderpath,[ runname,'.2',ext]));
catch
    file_data = importdata(fullfile(folderpath,[ runname,'.3',ext]));
end
data = file_data.data;

% First, find out how many periods there are and make a vector of them.
T = unique(data(:,1));

% I want the frequencies to go in ascending order, not the periods, so I
% will reverse the order of the periods.
if (T(1) ~= data(1,1));
    T = flipud(T);
end
%%% BUT it doesn't appear that this T vector is even used anymore, so
%%% ignore the above comment about reversing the periods.

% Second, find out how many direction there are and make a vector of them.
Beta = unique(data(:,2));

% how many modes are there.  make a vector of the indecies.
Modes = unique(data(:,3));

nb = length(Beta);
nt = length(T);
dof = length(Modes);

% make and empty matrix to read in the excitation forces
Forces = zeros(nt,nb,dof);

for i = 1:nt
    for j = 1:nb
        for k = 1:dof
            [re_im] = data((i-1)*nb*dof + (j-1)*dof + k, 6:7);
            Forces(i, j, k) = rho*g*complex(re_im(1), re_im(2));
        end
    end
end


