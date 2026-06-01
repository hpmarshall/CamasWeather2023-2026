%% download_snotel_camas_creek.m
%
% Downloads daily SNOTEL data for Camas Creek Divide (Station 382:ID:SNTL)
% from the NRCS AWDB reportGenerator API for water years 1992-2026.
%
% Variables downloaded:
%   WTEQ  - Snow Water Equivalent (in)
%   SNWD  - Snow Depth (in)          [NaN before sensor was installed ~2012]
%   PRCP  - Incremental Precipitation (in)
%   TMAX  - Air Temperature Maximum (degF)
%   TMIN  - Air Temperature Minimum (degF)
%   TAVG  - Air Temperature Average (degF)
%
% Output: snotel_camas_creek_WY1992_2026.mat
%
% NOTES:
%   The NRCS API returns multiple CSV blocks when the sensor suite changed
%   over time (e.g., SNWD added around 2010-2012). Each block has its own
%   header row with potentially different column names/order. This script
%   detects all blocks and uses keyword-based column matching per block.
%
%   The script prints each block's detected column mapping so you can
%   verify correct parsing. If pre-2010 SWE values look 10x too large,
%   the legacy data may be in tenths of inches — see the sanity-check
%   section near the end.
%
% NRCS reportGenerator API reference:
%   https://wcc.sc.egov.usda.gov/reportGenerator/
%
% Author: Hans-Peter Marshall, 2026-05-31

clear; clc;

%% --- Configuration ---------------------------------------------------

STATION    = '382';
STATE      = 'ID';
NETWORK    = 'SNTL';
WY_START   = 1992;
WY_END     = 2026;
OUT_FILE   = ['SNOTEL/snotel_camas_creek_WY1992_2026.mat'];

% Elements to request (variable::statistic)
ELEMENTS = strjoin({
    'WTEQ::value'   % Snow Water Equivalent
    'SNWD::value'   % Snow Depth
    'PRCP::value'   % Incremental Precipitation
    'TMAX::value'   % Max Air Temperature
    'TMIN::value'   % Min Air Temperature
    'TAVG::value'   % Average Air Temperature
    }, ',');

% Water year: Oct 1 of prior calendar year through Sep 30
date_start = sprintf('%d-10-01', WY_START - 1);   % e.g. 1991-10-01
date_end   = sprintf('%d-09-30', WY_END);          % e.g. 2026-09-30

%% --- Build API URL ---------------------------------------------------

base_url    = ['https://wcc.sc.egov.usda.gov/reportGenerator/' ...
               'view_csv/customSingleStationReport/daily/start_of_period'];
station_str = sprintf('%s:%s:%s|id=""|name', STATION, STATE, NETWORK);
url         = sprintf('%s/%s/%s,%s/%s', ...
                  base_url, station_str, date_start, date_end, ELEMENTS);

fprintf('Fetching data from NRCS API...\n');
fprintf('Station : %s:%s:%s (Camas Creek Divide)\n', STATION, STATE, NETWORK);
fprintf('Period  : %s to %s (WY%d-WY%d)\n', date_start, date_end, WY_START, WY_END);
fprintf('URL     : %s\n\n', url);

%% --- Download --------------------------------------------------------

options = weboptions('Timeout', 120, 'ContentType', 'text');
try
    raw = webread(url, options);
catch ME
    error('Download failed: %s\n', ME.message);
end
fprintf('Download complete (%d characters). Parsing...\n\n', numel(raw));

%% --- Split into lines and print metadata ----------------------------

lines = strsplit(raw, '\n');

fprintf('--- Station Metadata (from API comments) ---\n');
for i = 1:numel(lines)
    L = strtrim(lines{i});
    if startsWith(L, '#')
        if ~isempty(L), fprintf('%s\n', L); end
    else
        break;
    end
end
fprintf('--------------------------------------------\n\n');

%% --- Detect all header rows -----------------------------------------
% A header row is the first non-comment, non-blank line of each data block.
% Its first comma-delimited field is literally "Date".

is_header = false(numel(lines), 1);
for i = 1:numel(lines)
    L = strtrim(lines{i});
    if isempty(L) || startsWith(L, '#'), continue; end
    first_tok = strtrim(extractBefore([L ','], ','));
    if strcmpi(first_tok, 'Date')
        is_header(i) = true;
    end
end

header_rows = find(is_header);
if isempty(header_rows)
    error('No data header found. Check station ID / date range.');
end
fprintf('Found %d data block(s) in the API response.\n\n', numel(header_rows));

%% --- Parse each block with its own column mapping -------------------

all_dates = datetime.empty(0,1);
all_WTEQ = []; all_SNWD = []; all_PRCP = [];
all_TMAX = []; all_TMIN = []; all_TAVG = [];

for b = 1:numel(header_rows)
    hrow = header_rows(b);
    if b < numel(header_rows)
        drow_end = header_rows(b+1) - 1;
    else
        drow_end = numel(lines);
    end

    col_names = strtrim(strsplit(lines{hrow}, ','));

    % Keyword-based column resolution — robust to header rewording.
    % find_col_kw returns [] if no column matches all keywords (-> all NaN).
    col_date = find_col_kw(col_names, 'date');
    col_wteq = find_col_kw(col_names, 'snow water equivalent');
    col_snwd = find_col_kw(col_names, 'snow depth');
    col_prcp = find_col_kw(col_names, 'precipitation', 'increment');
    col_tmax = find_col_kw(col_names, 'temperature', 'maximum');
    col_tmin = find_col_kw(col_names, 'temperature', 'minimum');
    col_tavg = find_col_kw(col_names, 'temperature', 'average');

    fprintf('Block %d  (header at line %d, %d columns):\n', b, hrow, numel(col_names));
    for c = 1:numel(col_names)
        fprintf('  col %d: %s\n', c, col_names{c});
    end
    fprintf('  -> Date:%s  WTEQ:%s  SNWD:%s  PRCP:%s  Tmax:%s  Tmin:%s  Tavg:%s\n\n', ...
        col2str(col_date), col2str(col_wteq), col2str(col_snwd), col2str(col_prcp), ...
        col2str(col_tmax), col2str(col_tmin), col2str(col_tavg));

    % Gather data lines (skip blanks and comment lines)
    block_lines = lines(hrow+1:drow_end);
    keep = ~cellfun(@(l) isempty(strtrim(l)) || startsWith(strtrim(l),'#'), block_lines);
    block_lines = block_lines(keep);

    nb = numel(block_lines);
    b_dates = NaT(nb,1);
    b_WTEQ = nan(nb,1); b_SNWD = nan(nb,1); b_PRCP = nan(nb,1);
    b_TMAX = nan(nb,1); b_TMIN = nan(nb,1); b_TAVG = nan(nb,1);

    for i = 1:nb
        parts = strtrim(strsplit(block_lines{i}, ','));
        if numel(parts) < 2, continue; end

        if ~isempty(col_date)
            try
                b_dates(i) = datetime(parts{col_date}, 'InputFormat', 'yyyy-MM-dd');
            catch
                continue;
            end
        end

        b_WTEQ(i) = safe_parse(parts, col_wteq);
        b_SNWD(i) = safe_parse(parts, col_snwd);
        b_PRCP(i) = safe_parse(parts, col_prcp);
        b_TMAX(i) = safe_parse(parts, col_tmax);
        b_TMIN(i) = safe_parse(parts, col_tmin);
        b_TAVG(i) = safe_parse(parts, col_tavg);
    end

    valid = ~isnat(b_dates);
    all_dates = [all_dates; b_dates(valid)]; %#ok<AGROW>
    all_WTEQ  = [all_WTEQ;  b_WTEQ(valid)]; %#ok<AGROW>
    all_SNWD  = [all_SNWD;  b_SNWD(valid)]; %#ok<AGROW>
    all_PRCP  = [all_PRCP;  b_PRCP(valid)]; %#ok<AGROW>
    all_TMAX  = [all_TMAX;  b_TMAX(valid)]; %#ok<AGROW>
    all_TMIN  = [all_TMIN;  b_TMIN(valid)]; %#ok<AGROW>
    all_TAVG  = [all_TAVG;  b_TAVG(valid)]; %#ok<AGROW>
end

% Sort chronologically
[dates, idx] = sort(all_dates);
WTEQ = all_WTEQ(idx);
SNWD = all_SNWD(idx);
PRCP = all_PRCP(idx);
TMAX = all_TMAX(idx);
TMIN = all_TMIN(idx);
TAVG = all_TAVG(idx);

fprintf('Total records merged: %d  (%s to %s)\n\n', numel(dates), ...
    datestr(dates(1),'yyyy-mm-dd'), datestr(dates(end),'yyyy-mm-dd'));

%% --- Water-year derived fields --------------------------------------

water_year    = year(dates) + (month(dates) >= 10);
wy_start_date = datetime(water_year - 1, 10, 1);
dowy          = days(dates - wy_start_date) + 1;

%% --- Summary statistics ---------------------------------------------

fprintf('--- Data Summary ---\n');
fprintf('%-12s %6s   %8s %8s %8s\n', 'Variable','N_valid','Mean','Min','Max');
print_summary('SWE (in)',    WTEQ, '%6.2f');
print_summary('Depth (in)',  SNWD, '%6.1f');
print_summary('Precip (in)', PRCP, '%6.3f');
print_summary('Tmax (F)',    TMAX, '%6.1f');
print_summary('Tmin (F)',    TMIN, '%6.1f');
print_summary('Tavg (F)',    TAVG, '%6.1f');

%% --- Save -----------------------------------------------------------

station_info.name     = 'Camas Creek Divide';
station_info.id       = STATION;
station_info.state    = STATE;
station_info.network  = NETWORK;
station_info.triplet  = sprintf('%s:%s:%s', STATION, STATE, NETWORK);
station_info.wy_start = WY_START;
station_info.wy_end   = WY_END;
station_info.units    = struct( ...
    'WTEQ','inches', 'SNWD','inches', ...
    'PRCP','inches (incremental daily)', ...
    'TMAX','degrees F', 'TMIN','degrees F', 'TAVG','degrees F');

save(OUT_FILE, 'dates', 'water_year', 'dowy', ...
    'WTEQ', 'SNWD', 'PRCP', 'TMAX', 'TMIN', 'TAVG', ...
    'station_info', '-v7.3');
fprintf('\nSaved: %s\n', OUT_FILE);

%% --- Overview plot --------------------------------------------------

figure('Name','Camas Creek Divide SNOTEL - Overview', ...
       'NumberTitle','off','Position',[80 80 1200 820]);

subplot(3,2,1);
plot(dates, WTEQ, 'b-', 'LineWidth', 0.5);
ylabel('SWE (in)'); title('Snow Water Equivalent'); grid on;

subplot(3,2,2);
plot(dates, SNWD, 'c-', 'LineWidth', 0.5);
ylabel('Depth (in)'); title('Snow Depth  [NaN before sensor ~2012]'); grid on;

subplot(3,2,3);
plot(dates, PRCP, 'g-', 'LineWidth', 0.5);
ylabel('Precip (in)'); title('Incremental Precipitation'); grid on;

subplot(3,2,4);
plot(dates, TMAX, 'r-', 'LineWidth', 0.5); hold on;
plot(dates, TMIN, 'b-', 'LineWidth', 0.5);
plot(dates, TAVG, 'k-', 'LineWidth', 0.8);
ylabel('Temp (°F)'); title('Air Temperature');
legend('Tmax','Tmin','Tavg','Location','best'); grid on;

subplot(3,2,[5 6]);
wy_list  = WY_START:WY_END;
peak_swe = arrayfun(@(wy) nanmax(WTEQ(water_year == wy)), wy_list);
bar(wy_list, peak_swe, 'FaceColor', [0.2 0.5 0.8]);
xlabel('Water Year'); ylabel('Peak SWE (in)');
title('Annual Peak SWE'); grid on;

sgtitle('Camas Creek Divide SNOTEL (382:ID:SNTL)', ...
    'FontSize', 13, 'FontWeight', 'bold');

fprintf('Done.\n');

%% ===== LOCAL FUNCTIONS (must be at end of script file) ==============

function col = find_col_kw(col_names, varargin)
% Returns index of first column whose name contains ALL keyword strings.
% Case-insensitive. Returns [] if no match found.
    col = [];
    for k = 1:numel(col_names)
        name_lc = lower(col_names{k});
        hit = true;
        for kw = varargin
            if ~contains(name_lc, lower(kw{1}))
                hit = false; break;
            end
        end
        if hit, col = k; return; end
    end
end

function val = safe_parse(parts, col)
% Parse a numeric value from a cell array of strings.
% Returns NaN if col is empty, out of range, or non-numeric.
    val = NaN;
    if isempty(col) || col > numel(parts), return; end
    s = strtrim(parts{col});
    if isempty(s), return; end
    v = str2double(s);
    if ~isnan(v), val = v; end
end

function s = col2str(col)
% Format column index (or []) as a display string.
    if isempty(col), s = '—'; else, s = num2str(col); end
end

function print_summary(label, x, fmt)
% Print one row of the summary table.
    n = sum(~isnan(x));
    fprintf(['%-12s %6d   ' fmt '   ' fmt '   ' fmt '\n'], ...
        label, n, nanmean(x), nanmin(x), nanmax(x));
end
