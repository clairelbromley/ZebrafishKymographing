timestamps = zeros(length(fls_with_idx),1);
timestamps(~fls_with_idx) = ts(~fls_with_idx);

unq_ts = ts(~fls_with_idx);

for tidx = 1:length(unq_ts)
    t = unq_ts(tidx);
    fs = (ts(:,1) == t);
    times = ts(((ts(:,1) == t ) & (~fls_with_idx)),...
        1:n_T_planes(((ts(:,1) == t ) & (~fls_with_idx))));
    timestamps((ts(:,1) == t ) & (fls_with_idx)) = times(2:end);
end
    
timestamps = timestamps - min(timestamps);