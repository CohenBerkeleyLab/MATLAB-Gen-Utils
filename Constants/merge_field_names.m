function [ Names, dates, directory, range_file ] = merge_field_names( campaign_name )
%merge_field_names Returns field names of key fields in merge files
%   Different field campaigns name the same data differently.  This
%   function will return a structure with all the appropriate field names
%   for use in any other functions.  This allows this function to be a
%   central clearing house for field names that any other function can make
%   use of.
%
%   Valid campaign designations are:
%       arctas
%       seac3rs/seacers
%       discover-md/ca/tx
%   This function will try to match the input string to one of these; it is
%   not especially picky, so for example discovermd, Discover-MD, and
%   Discover-AQ MD will all successfully indicate to use the field names
%   from the Maryland Discover-AQ campaign.  If no campaign name can be
%   matched, an error is thrown.
%
%   Fields returned are:
%       pressure_alt - pressure derived altitude
%       gps_alt - GPS derived altitude
%       radar_alt - radar altitude, i.e. altitude above the ground
%       theta - potential temperature measurements
%       no2_lif - Our (Cohen group) NO2 measurements
%       no2_ncar - Andy Weinheimer's NO2 measurmenets
%       aerosol_extinction - Aerosol extinction measurments at green 
%           wavelengths
%       aerosol_scattering - Aerosol scattering only measurements (no
%           absorption)
%       aerosol_ssa - Aerosol single scattering albedo measurements
%       profile_numbers - The field with the number assigned to each
%           profile. Only a field in DISCOVER campaigns.
%   Any field that doesn't exist for a given campaign returns an empty
%   string.
%
%   This also returns (as additional outputs) the dates for the campaign,
%   the directory where the merge files can be found, and (if available)
%   the UTC ranges file used to define profiles for campaigns without
%   predefined profile numbers.  In the case where multiple range files are
%   available, this function will ask the user which one to use.

E = JLLErrors;

% Setup the fields the output structure is expected to have - this will be
% validated against before the structure is returned.  That way, if I make
% a mistake adding a new campaign we can avoid instances of other functions
% expecting a field to be no2_lif and getting one that is NO2_LIF.  ADD ANY
% ADDITIONAL FIELDS TO RETURN HERE.
return_fields = {'pressure_alt', 'gps_alt', 'radar_alt', 'temperature', 'pressure','theta', 'no2_lif', 'no2_ncar',...
    'aerosol_extinction', 'aerosol_scattering','aerosol_ssa','aerosol_dry_ssa', 'profile_numbers'}';

% Initialize the return variables
for a=1:numel(return_fields)
    Names.(return_fields{a}) = '';
end

dates = cell(1,2);
directory = '';
range_files = {''};

% All campaign data should be stored in a central directory, this is that
% directory
main_dir = '/Volumes/share2/USERS/LaughnerJ/CampaignMergeMats';

% Parse the campaign name and assign the fields

% DISCOVER-MD
if ~isempty(regexpi(campaign_name,'discover')) && ~isempty(regexpi(campaign_name,'md'))
    Names.pressure_alt = 'ALTP';
    Names.gps_alt = 'GPS_ALT';
    Names.radar_alt = 'A_RadarAlt';
    Names.temperature = 'TEMPERATURE';
    Names.pressure = 'PRESSURE';
    Names.theta = 'THETA';
    Names.no2_lif = 'NO2_LIF';
    Names.no2_ncar = 'NO2_NCAR';
    Names.aerosol_extinction = 'EXTamb532';
    Names.aerosol_scattering = 'SCamb532';
    Names.aerosol_ssa = 'SingleScatteringAlbedo_at_550nmambient';
    Names.aerosol_dry_ssa = 'SingleScatteringAlbedo_at_550nm';
    Names.profile_numbers = 'ProfileSequenceNum';
    
    dates = {'2011-07-01','2011-07-31'};
    directory = fullfile(main_dir,'DISCOVER-AQ_MD/P3/1sec/');

% DISCOVER-CA
elseif ~isempty(regexpi(campaign_name,'discover')) && ~isempty(regexpi(campaign_name,'ca'))
    Names.pressure_alt = 'ALTP';
    Names.gps_alt = 'GPS_ALT';
    Names.radar_alt = 'Radar_Altitude';
    Names.temperature = 'TEMPERATURE';
    Names.pressure = 'PRESSURE';
    Names.theta = 'THETA';
    Names.no2_lif = 'NO2_MixingRatio_LIF';
    Names.no2_ncar = 'NO2_MixingRatio';
    Names.aerosol_extinction = 'EXTamb532_TSI_PSAP';
    Names.aerosol_scattering = 'SCATamb532_TSI';
    Names.aerosol_ssa = 'SingleScatAlbedo550amb_TSIneph_PSAP';
    Names.aerosol_dry_ssa = 'SingleScatAlbedo550dry_TSIneph_PSAP';
    Names.profile_numbers = 'ProfileNumber';
    
    dates = {'2013-01-16','2013-02-06'};
    directory = fullfile(main_dir, 'DISCOVER-AQ_CA/P3/1sec/');
    
% DISCOVER-TX
elseif ~isempty(regexpi(campaign_name,'discover')) && ~isempty(regexpi(campaign_name,'tx'))
    Names.pressure_alt = 'ALTP';
    Names.gps_alt = 'GPS_ALT';
    Names.radar_alt = 'Radar_Altitude';
    Names.temperature = 'TEMPERATURE';
    Names.pressure = 'PRESSURE';
    Names.theta = 'THETA';
    Names.no2_lif = 'NO2_MixingRatio_LIF';
    Names.no2_ncar = 'NO2_MixingRatio';
    Names.aerosol_extinction = 'EXT532nmamb_total_LARGE';
    Names.aerosol_scattering = 'SCAT550nm-amb_total_LARGE,';
    Names.aerosol_ssa = 'SSA550nmamb_LARGE';
    Names.aerosol_dry_ssa = 'SSA550nmdry_LARGE';
    Names.profile_numbers = 'ProfileNumber';
    
    dates = {'2013-09-01','2013-09-30'};
    directory = fullfile(main_dir, 'DISCOVER-AQ_TX/P3/1sec/');
    
% SEAC4RS
elseif ~isempty(regexpi(campaign_name,'seac4rs')) || ~isempty(regexpi(campaign_name,'seacers'));
    Names.pressure_alt = 'ALTP';
    Names.gps_alt = 'GPS_ALT';
    Names.radar_alt = 'RadarAlt';
    Names.temperature = 'TEMPERATURE';
    Names.pressure = 'PRESSURE';
    Names.theta = 'THETA';
    Names.no2_lif = 'NO2_TDLIF';
    Names.no2_ncar = 'NO2_ESRL'; % This is Ryerson's NO2, not sure if that's different from Weinheimer's
    Names.aerosol_extinction = 'EXT532nmamb_total_LARGE';
    Names.aerosol_scattering = 'SCAT550nmamb_total_LARGE';
    Names.aerosol_ssa = 'SSA550nmamb_TSIandPSAP_LARGE';
    Names.aerosol_dry_ssa = 'SSA550nmdry_TSIandPSAP_LARGE';
    
    dates = {'2013-08-06','2013-09-23'};
    directory = fullfile(main_dir, 'SEAC4RS/DC8/1sec/');
    
    range_files = {fullfile(main_dir, 'SEAC4RS/SEAC4RS_Profile_Ranges.mat')};

% DC3 (not to be confused with the DC8 aircraft)
elseif ~isempty(regexpi(campaign_name,'dc3'))
    Names.pressure_alt = 'ALTP';
    Names.gps_alt = 'GPS_ALT';
    Names.radar_alt = 'RadarAlt';
    Names.temperature = 'TEMPERATURE';
    Names.pressure = 'PRESSURE';
    Names.theta = 'THETA';
    Names.no2_lif = 'NO2_TDLIF';
    Names.no2_ncar = 'NO2_ESRL'; % This is Ryerson's NO2, not sure if that's different from Weinheimer's
    Names.aerosol_extinction = 'EXTamb532nm_TSI_PSAP';
    Names.aerosol_scattering = 'SCATamb532nm_TSI';
    Names.aerosol_ssa = 'SingleScatAlbedo_amb550nm_TSIneph_PSAP';
    Names.aerosol_dry_ssa = 'SingleScatAlbedo_dry700nm_TSIneph_PSAP';
    
    dates = {'2012-05-18','2012-06-22'};
    directory = fullfile(main_dir, 'DC3/DC8/1sec/');
    
% ARCTAS (-B and -CARB)
elseif ~isempty(regexpi(campaign_name,'arctas'))
    Names.pressure_alt = 'ALTP';
    Names.gps_alt = 'GPS_Altitude';
    Names.radar_alt = 'Radar_Altitude';
    Names.temperature = 'TEMPERATURE';
    Names.pressure = 'PRESSURE';
    Names.theta = 'THETA';
    Names.no2_lif = 'NO2_UCB';
    Names.no2_ncar = 'NO2_NCAR';
    Names.aerosol_extinction = 0;
    Names.aerosol_scattering = 'Total_Scatter550_nm';
    % For Arctas, it is not specified whether these are taken at ambient or
    % dry conditions.  Since other later campaigns only have dry data at
    % multiple wavelengths, I'm inclined to guess that this is actually dry
    % data.
    Names.aerosol_ssa = 'Single_Scatter_Albedo_Green';
    Names.aerosol_dry_ssa = 'Single_Scatter_Albedo_Green';
    
    
    if ~isempty(regexpi(campaign_name,'carb'))
        dates = {'2008-06-18','2008-06-24'};
        directory = fullfile(main_dir,'ARCTAS-CARB/DC8/1sec/');
        range_files = {fullfile(main_dir, 'ARCTAS-CARB/ARCTAS-CA Altitude Ranges Exclusive 3.mat')};
    elseif ~isempty(regexpi(campaign_name,'b'))
        dates = {'2008-06-29','2008-07-13'};
        directory = fullfile(main_dir,'ARCTAS-B/DC8/1sec/');
    end
    
% INTEX-B
elseif ~isempty(regexpi(campaign_name,'intex')) && ~isempty(regexpi(campaign_name,'b'))
    Names.pressure_alt = 'ALTITUDE_PRESSURE';
    Names.gps_alt = 'ALTITUDE_GPS';
    Names.radar_alt = 'ALTITUDE_RADAR';
    Names.temperature = 'TEMP_STAT_C';
    Names.pressure = 'STAT_PRESSURE';
    Names.theta = 'THETA';
    Names.no2_lif = 'NO2';
    Names.no2_ncar = ''; 
    Names.aerosol_extinction = 0;
    Names.aerosol_scattering = 0;
    Names.aerosol_ssa = 0;
    Names.aerosol_dry_ssa = 0;
    
    dates = {'2006-03-04','2006-05-15'};
    directory = fullfile(main_dir, 'INTEX-B/DC8/1sec/');
    
    range_files = {fullfile(main_dir, 'INTEX-B/INTEXB_Profile_UTC_Ranges.mat'),...
                   fullfile(main_dir, 'INTEX-B/INTEXB_Profile_UTC_Ranges_Inclusive.mat')};
else
    error(E.badinput('Could not parse the given campaign name - see help for this function for suggestions of proper campaign names.'));
end


% If there is only one range file, return it. If there are multiple
% options, ask the user which one to use (and don't continue until the
% input is valid).  If there is not a range file specified, return an empty
% string.  Only do this if the range file is actually output to a variable,
% otherwise, don't waste the user's time.

if nargout >= 4
    n = numel(range_files);
    if n == 1
        range_file = range_files{1};
    elseif n > 1
        while true
            opts_nums = 1:n;
            opts_str = cell(1,n);
            for a=1:n
                [~,file] = fileparts(range_files{a});
                opts_str{a} = sprintf('%d: %s',opts_nums(a),file);
            end
            opts_spec = repmat('\t%s\n',1,n);
            opts_msg = sprintf('Enter the number for which range file to use:\n%s> ',opts_spec);
            rf_choice = input(sprintf(opts_msg,opts_str{:}));
            if rf_choice >= 1 && rf_choice <= n
                range_file = range_files{rf_choice};
                break;
            else
                fprintf('\n\n%d is not a valid option.\n',rf_choice);
            end
        end
    else
        range_file = '';
    end
end


% Check that all the fields of the output structure are what we expect
fields = fieldnames(Names);
if numel(fields) ~= numel(return_fields) || ~all(strcmp(fields,return_fields))
    error(E.callError('internal:fields_mismatch','Fields of output structure are not what is expected. Make sure any new fields are spelled correctly and that they have been added to ''return_fields'''));
end


end
