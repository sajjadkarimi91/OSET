function Z = ECGModelTimeBased(X,time)
%
% A time-based version of ECGModel() for generating a sum of Gaussian
% model.
%
% Open Source ECG Toolbox, version 3.14, February 2019
% Released under the GNU General Public License
% Copyright (C) 2019  Reza Sameni
% reza.sameni@gmail.com

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.

L = (length(X)/3);

alphai = X(1:L);
bi = X(L+1:2*L);
tetai = X(2*L+1:3*L);

Z = zeros(size(time));
for j = 1:length(alphai),
    dtetai = time - tetai(j);
    Z = Z + alphai(j) .* exp(-dtetai .^2 ./ (2*bi(j) .^ 2));
end