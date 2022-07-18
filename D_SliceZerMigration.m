
function oldversionTF = D_SliceZerMigration(fileName,inputData)

maxFileNum = 10;

% Create the new variable for Vm -----------------------
VmMap = cell(4,3);
VmMap{1,1} = 'Act';
VmMap{2,1} = 'Rep';
VmMap{3,1} = 'APD';
VmMap{4,1} = 'RT';

ActMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'LB', 'UB', 'Pseudo Data Time', 'Data Section', ...
    'Locs Act', 'Act Matrix', 'Ensemble Peaks Number' };
ActMapData = cell(1,11,maxFileNum);
VmMap{1,2} = ActMapDataTitle;
VmMap{1,3} = ActMapData;
clear ActMapDataTitle ActMapData

RepMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'Rep Level', 'LB', 'UB', 'Pseudo Data Time', 'Data Section', ...
    'Locs Rep', 'Rep Matrix', 'Ensemble Peaks Number' };
RepMapData = cell(1,12,maxFileNum);
VmMap{2,2} = RepMapDataTitle;
VmMap{2,3} = RepMapData;
clear RepMapDataTitle RepMapData

APDMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'APD Level', 'LB', 'UB', 'Pseudo Data Time', 'Data Section', ...
    'Locs Act', 'Locs Rep', 'APD Matrix', 'Ensemble Peaks Number' };
APDMapData = cell(1,13,maxFileNum);
VmMap{3,2} = APDMapDataTitle;
VmMap{3,3} = APDMapData;
clear APDMapDataTitle APDMapData

RTMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'Start Level', 'End Level', 'LB', 'UB', 'Pseudo Data Time', 'Data Section', ...
    'Locs Start', 'Locs End', 'RT Matrix', 'Ensemble Peaks Number' };
RTMapData = cell(1,14,maxFileNum);
VmMap{4,2} = RTMapDataTitle;
VmMap{4,3} = RTMapData;
clear RTMapDataTitle RTMapData

VmMapEmpty = VmMap;



% Create the new variable for Ca -----------------------
CaMap = cell(6,3);
CaMap{1,1} = 'Act';
CaMap{2,1} = 'Rep';
CaMap{3,1} = 'CaTD';
CaMap{4,1} = 'RT';
CaMap{5,1} = 'DT';
CaMap{6,1} = 'DTau';

ActMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'LB', 'UB', 'Pseudo Data Time', 'Data Section', ...
    'Locs Act', 'Act Matrix', 'Ensemble Peaks Number' };
ActMapData = cell(1,11,maxFileNum);
CaMap{1,2} = ActMapDataTitle;
CaMap{1,3} = ActMapData;
clear ActMapDataTitle ActMapData

RepMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'Rep Level', 'LB', 'UB', 'Pseudo Data Time', 'Data Section', ...
    'Locs Rep', 'Rep Matrix', 'Ensemble Peaks Number' };
RepMapData = cell(1,12,maxFileNum);
CaMap{2,2} = RepMapDataTitle;
CaMap{2,3} = RepMapData;
clear RepMapDataTitle RepMapData

CaTDMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'CaTD Level', 'LB', 'UB', 'Pseudo Data Time', 'Data Section', ...
    'Locs Act', 'Locs Rep', 'CaTD Matrix', 'Ensemble Peaks Number' };
CaTDMapData = cell(1,13,maxFileNum);
CaMap{3,2} = CaTDMapDataTitle;
CaMap{3,3} = CaTDMapData;
clear CaTDMapDataTitle CaTDMapData

RTMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'Start Level', 'End Level', 'LB', 'UB', 'Pseudo Data Time', 'Data Section', ...
    'Locs Start', 'Locs End', 'RT Matrix', 'Ensemble Peaks Number' };
RTMapData = cell(1,14,maxFileNum);
CaMap{4,2} = RTMapDataTitle;
CaMap{4,3} = RTMapData;
clear RTMapDataTitle RTMapData

DTMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'Start Level', 'End Level', 'LB', 'UB', 'Pseudo Data Time', 'Data Section', ...
    'Locs Start', 'Locs End', 'DT Matrix', 'Ensemble Peaks Number' };
DTMapData = cell(1,14,maxFileNum);
CaMap{5,2} = DTMapDataTitle;
CaMap{5,3} = DTMapData;
clear DTMapDataTitle DTMapData

DTauMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
    'Start Level', 'End Level', 'LB', 'UB', 'Pseudo Data Time', 'Data Section', 'Fit Data Section', ...
    'Locs Start', 'Locs End', 'DTau Matrix', 'Ensemble Peaks Number' };
DTauMapData = cell(1,15,maxFileNum);
CaMap{6,2} = DTauMapDataTitle;
CaMap{6,3} = DTauMapData;
clear DTauMapDataTitle DTauMapData

CaMapEmpty = CaMap;



% ------------------------------------------------------------- %
oldversionTF = 0; % '0' or ('1') - 'new' or ('old') version

totalSectionNum = 7;



%% ------------------------------------------------------------- %
% Version Check Type I
sectionID = 1;


% Re-Arrange Variables for camera 1 -----------------------
field = { 'vRegionalActMap', 'vGlobalActMap', ...
    'vRegionalRepMap', 'vGlobalRepMap', ...
    'vRegionalSingleRTMap', 'vGlobalSingleRTMap', 'vRegionalEnsembleRTMap', 'vGlobalEnsembleRTMap', ...
    'regionalSingleAPDMap', 'regionalEnsembleAPDMap', 'globalSingleAPDMap', 'globalEnsembleAPDMap', ...
    'VmACV' };

TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)

% Need to migrate from old SliceZer to new version
if TF == 1
    
    oldversionTF = 1; % Old version
    
    msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
    f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
    
    
    % Act map -----------------------
    actPage = 1;
    
    if ~isempty( inputData.vRegionalActMap )
        
        label = inputData.vRegionalActMap{1}.regionalActivationLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{1,3}{1,1,actPage} = round(num1 * inputData.acqFreq);
        VmMap{1,3}{1,2,actPage} = round(num2 * inputData.acqFreq);
        VmMap{1,3}{1,3,actPage} = 'Regional';
        VmMap{1,3}{1,4,actPage} = 'Single';
        VmMap{1,3}{1,5,actPage} = inputData.vRegionalActMap{1}.regionalActLB;
        VmMap{1,3}{1,6,actPage} = inputData.vRegionalActMap{1}.regionalActUB;
        VmMap{1,3}{1,7,actPage} = inputData.vRegionalActMap{1}.regionalActPseudoDataTime;
        VmMap{1,3}{1,8,actPage} = inputData.vRegionalActMap{1}.actRegionalDataSection;
        VmMap{1,3}{1,9,actPage} = inputData.vRegionalActMap{1}.regionalActLocsAct;
        VmMap{1,3}{1,10,actPage} = inputData.vRegionalActMap{1}.regionalRelativeActMatrix;
        VmMap{1,3}{1,11,actPage} = [];
        
        actPage = actPage + 1;
    end
    
    if ~isempty( inputData.vGlobalActMap )
        
        label = inputData.vGlobalActMap{1}.globalActivationLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{1,3}{1,1,actPage} = round(num1 * inputData.acqFreq);
        VmMap{1,3}{1,2,actPage} = round(num2 * inputData.acqFreq);
        VmMap{1,3}{1,3,actPage} = 'Global';
        VmMap{1,3}{1,4,actPage} = 'Single';
        VmMap{1,3}{1,5,actPage} = inputData.vGlobalActMap{1}.globalActLB;
        VmMap{1,3}{1,6,actPage} = inputData.vGlobalActMap{1}.globalActUB;
        VmMap{1,3}{1,7,actPage} = inputData.vGlobalActMap{1}.globalActPseudoDataTime;
        VmMap{1,3}{1,8,actPage} = inputData.vGlobalActMap{1}.actGlobalDataSection;
        VmMap{1,3}{1,9,actPage} = inputData.vGlobalActMap{1}.globalActLocsAct;
        VmMap{1,3}{1,10,actPage} = inputData.vGlobalActMap{1}.globalRelativeActMatrix;
        VmMap{1,3}{1,11,actPage} = [];
    end
    
    
    % Rep map -----------------------
    repPage = 1;
    
    if ~isempty( inputData.vRegionalRepMap )
        
        label = inputData.vRegionalRepMap{1}.RegionalRepolarisationLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{2,3}{1,1,repPage} = round(num1 * inputData.acqFreq);
        VmMap{2,3}{1,2,repPage} = round(num2 * inputData.acqFreq);
        VmMap{2,3}{1,3,repPage} = 'Regional';
        VmMap{2,3}{1,4,repPage} = 'Single';
        VmMap{2,3}{1,5,repPage} = inputData.vRegionalRepMap{1}.regionalRepLevel;
        VmMap{2,3}{1,6,repPage} = inputData.vRegionalRepMap{1}.regionalRepLB;
        VmMap{2,3}{1,7,repPage} = inputData.vRegionalRepMap{1}.regionalRepUB;
        VmMap{2,3}{1,8,repPage} = inputData.vRegionalRepMap{1}.regionalRepPseudoDataTime;
        VmMap{2,3}{1,9,repPage} = inputData.vRegionalRepMap{1}.repRegionalDataSection;
        VmMap{2,3}{1,10,repPage} = inputData.vRegionalRepMap{1}.regionalRepLocsRep;
        VmMap{2,3}{1,11,repPage} = inputData.vRegionalRepMap{1}.regionalRelativeRepMatrix;
        VmMap{2,3}{1,12,repPage} = [];
        
        repPage = repPage + 1;
    end
    
    if ~isempty( inputData.vGlobalRepMap )
        
        label = inputData.vGlobalRepMap{1}.GlobalRepolarisationLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{2,3}{1,1,repPage} = round(num1 * inputData.acqFreq);
        VmMap{2,3}{1,2,repPage} = round(num2 * inputData.acqFreq);
        VmMap{2,3}{1,3,repPage} = 'Global';
        VmMap{2,3}{1,4,repPage} = 'Single';
        VmMap{2,3}{1,5,repPage} = inputData.vGlobalRepMap{1}.globalRepLevel;
        VmMap{2,3}{1,6,repPage} = inputData.vGlobalRepMap{1}.globalRepLB;
        VmMap{2,3}{1,7,repPage} = inputData.vGlobalRepMap{1}.globalRepUB;
        VmMap{2,3}{1,8,repPage} = inputData.vGlobalRepMap{1}.globalRepPseudoDataTime;
        VmMap{2,3}{1,9,repPage} = inputData.vGlobalRepMap{1}.repGlobalDataSection;
        VmMap{2,3}{1,10,repPage} = inputData.vGlobalRepMap{1}.globalRepLocsRep;
        VmMap{2,3}{1,11,repPage} = inputData.vGlobalRepMap{1}.globalRelativeRepMatrix;
        VmMap{2,3}{1,12,repPage} = [];
    end
    
    
    % APD map -----------------------
    APDPage = 1;
    
    if ~isempty( inputData.regionalSingleAPDMap )
        
        label = inputData.regionalSingleAPDMap{1}.regionalSingleAPDLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{3,3}{1,1,APDPage} = round(num1 * inputData.acqFreq);
        VmMap{3,3}{1,2,APDPage} = round(num2 * inputData.acqFreq);
        VmMap{3,3}{1,3,APDPage} = 'Regional';
        VmMap{3,3}{1,4,APDPage} = 'Single';
        VmMap{3,3}{1,5,APDPage} = inputData.regionalSingleAPDMap{1}.regionalSingleAPDRepLevel;
        VmMap{3,3}{1,6,APDPage} = inputData.regionalSingleAPDMap{1}.regionalSingleAPDLB;
        VmMap{3,3}{1,7,APDPage} = inputData.regionalSingleAPDMap{1}.regionalSingleAPDUB;
        VmMap{3,3}{1,8,APDPage} = inputData.regionalSingleAPDMap{1}.regionalSingleAPDPseudoDataTime;
        VmMap{3,3}{1,9,APDPage} = inputData.regionalSingleAPDMap{1}.APDRegionalSingleDataSection;
        VmMap{3,3}{1,10,APDPage} = inputData.regionalSingleAPDMap{1}.regionalSingleAPDLocsAct;
        VmMap{3,3}{1,11,APDPage} = inputData.regionalSingleAPDMap{1}.regionalSingleAPDLocsRep;
        VmMap{3,3}{1,12,APDPage} = inputData.regionalSingleAPDMap{1}.regionalSingleAPDMatrix;
        VmMap{3,3}{1,13,APDPage} = [];
        
        APDPage = APDPage + 1;
    end
    
    if ~isempty( inputData.regionalEnsembleAPDMap )
        
        label = inputData.regionalEnsembleAPDMap{1}.regionalEnsembleAPDLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{3,3}{1,1,APDPage} = round(num1 * inputData.acqFreq);
        VmMap{3,3}{1,2,APDPage} = round(num2 * inputData.acqFreq);
        VmMap{3,3}{1,3,APDPage} = 'Regional';
        VmMap{3,3}{1,4,APDPage} = 'Ensemble';
        VmMap{3,3}{1,5,APDPage} = inputData.regionalEnsembleAPDMap{1}.regionalEnsembleAPDRepLevel;
        VmMap{3,3}{1,6,APDPage} = inputData.regionalEnsembleAPDMap{1}.regionalEnsembleAPDLB;
        VmMap{3,3}{1,7,APDPage} = inputData.regionalEnsembleAPDMap{1}.regionalEnsembleAPDUB;
        VmMap{3,3}{1,8,APDPage} = inputData.regionalEnsembleAPDMap{1}.regionalEnsembleAPDPseudoDataTime;
        VmMap{3,3}{1,9,APDPage} = inputData.regionalEnsembleAPDMap{1}.APDRegionalEnsembleDataSection;
        VmMap{3,3}{1,10,APDPage} = inputData.regionalEnsembleAPDMap{1}.regionalEnsembleAPDLocsAct;
        VmMap{3,3}{1,11,APDPage} = inputData.regionalEnsembleAPDMap{1}.regionalEnsembleAPDLocsRep;
        VmMap{3,3}{1,12,APDPage} = inputData.regionalEnsembleAPDMap{1}.regionalEnsembleAPDMatrix;
        VmMap{3,3}{1,13,APDPage} = inputData.regionalEnsembleAPDMap{1}.regionalEnsembleAPDPksNum;
        
        APDPage = APDPage + 1;
    end
    
    if ~isempty( inputData.globalSingleAPDMap )
        
        label = inputData.globalSingleAPDMap{1}.globalSingleAPDLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{3,3}{1,1,APDPage} = round(num1 * inputData.acqFreq);
        VmMap{3,3}{1,2,APDPage} = round(num2 * inputData.acqFreq);
        VmMap{3,3}{1,3,APDPage} = 'Global';
        VmMap{3,3}{1,4,APDPage} = 'Single';
        VmMap{3,3}{1,5,APDPage} = inputData.globalSingleAPDMap{1}.globalSingleAPDRepLevel;
        VmMap{3,3}{1,6,APDPage} = inputData.globalSingleAPDMap{1}.globalSingleAPDLB;
        VmMap{3,3}{1,7,APDPage} = inputData.globalSingleAPDMap{1}.globalSingleAPDUB;
        VmMap{3,3}{1,8,APDPage} = inputData.globalSingleAPDMap{1}.globalSingleAPDPseudoDataTime;
        VmMap{3,3}{1,9,APDPage} = inputData.globalSingleAPDMap{1}.APDGlobalSingleDataSection;
        VmMap{3,3}{1,10,APDPage} = inputData.globalSingleAPDMap{1}.globalSingleAPDLocsAct;
        VmMap{3,3}{1,11,APDPage} = inputData.globalSingleAPDMap{1}.globalSingleAPDLocsRep;
        VmMap{3,3}{1,12,APDPage} = inputData.globalSingleAPDMap{1}.globalSingleAPDMatrix;
        VmMap{3,3}{1,13,APDPage} = [];
        
        APDPage = APDPage + 1;
    end
    
    if ~isempty( inputData.globalEnsembleAPDMap )
        
        label = inputData.globalEnsembleAPDMap{1}.globalEnsembleAPDLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{3,3}{1,1,APDPage} = round(num1 * inputData.acqFreq);
        VmMap{3,3}{1,2,APDPage} = round(num2 * inputData.acqFreq);
        VmMap{3,3}{1,3,APDPage} = 'Global';
        VmMap{3,3}{1,4,APDPage} = 'Ensemble';
        VmMap{3,3}{1,5,APDPage} = inputData.globalEnsembleAPDMap{1}.globalEnsembleAPDRepLevel;
        VmMap{3,3}{1,6,APDPage} = inputData.globalEnsembleAPDMap{1}.globalEnsembleAPDLB;
        VmMap{3,3}{1,7,APDPage} = inputData.globalEnsembleAPDMap{1}.globalEnsembleAPDUB;
        VmMap{3,3}{1,8,APDPage} = inputData.globalEnsembleAPDMap{1}.globalEnsembleAPDPseudoDataTime;
        VmMap{3,3}{1,9,APDPage} = inputData.globalEnsembleAPDMap{1}.APDGlobalEnsembleDataSection;
        VmMap{3,3}{1,10,APDPage} = inputData.globalEnsembleAPDMap{1}.globalEnsembleAPDLocsAct;
        VmMap{3,3}{1,11,APDPage} = inputData.globalEnsembleAPDMap{1}.globalEnsembleAPDLocsRep;
        VmMap{3,3}{1,12,APDPage} = inputData.globalEnsembleAPDMap{1}.globalEnsembleAPDMatrix;
        VmMap{3,3}{1,13,APDPage} = inputData.globalEnsembleAPDMap{1}.globalEnsembleAPDPksNum;
    end
    
    
    % RT map -----------------------
    RTPage = 1;
    
    if ~isempty( inputData.vRegionalSingleRTMap )
        
        label = inputData.vRegionalSingleRTMap{1}.regionalSingleRTLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{4,3}{1,1,RTPage} = round(num1 * inputData.acqFreq);
        VmMap{4,3}{1,2,RTPage} = round(num2 * inputData.acqFreq);
        VmMap{4,3}{1,3,RTPage} = 'Regional';
        VmMap{4,3}{1,4,RTPage} = 'Single';
        VmMap{4,3}{1,5,RTPage} = inputData.vRegionalSingleRTMap{1}.regionalSingleRTStartLevel;
        VmMap{4,3}{1,6,RTPage} = inputData.vRegionalSingleRTMap{1}.regionalSingleRTEndLevel;
        VmMap{4,3}{1,7,RTPage} = inputData.vRegionalSingleRTMap{1}.regionalSingleRTLB;
        VmMap{4,3}{1,8,RTPage} = inputData.vRegionalSingleRTMap{1}.regionalSingleRTUB;
        VmMap{4,3}{1,9,RTPage} = inputData.vRegionalSingleRTMap{1}.regionalSingleRTPseudoDataTime;
        VmMap{4,3}{1,10,RTPage} = inputData.vRegionalSingleRTMap{1}.RTRegionalSingleDataSection;
        VmMap{4,3}{1,11,RTPage} = inputData.vRegionalSingleRTMap{1}.regionalSingleRTLocsStart;
        VmMap{4,3}{1,12,RTPage} = inputData.vRegionalSingleRTMap{1}.regionalSingleRTLocsEnd;
        VmMap{4,3}{1,13,RTPage} = inputData.vRegionalSingleRTMap{1}.regionalSingleRTMatrix;
        VmMap{4,3}{1,14,RTPage} = [];
        
        RTPage = RTPage + 1;
    end
    
    if ~isempty( inputData.vRegionalEnsembleRTMap )
        
        label = inputData.vRegionalEnsembleRTMap{1}.regionalEnsembleRTLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{4,3}{1,1,RTPage} = round(num1 * inputData.acqFreq);
        VmMap{4,3}{1,2,RTPage} = round(num2 * inputData.acqFreq);
        VmMap{4,3}{1,3,RTPage} = 'Regional';
        VmMap{4,3}{1,4,RTPage} = 'Ensemble';
        VmMap{4,3}{1,5,RTPage} = inputData.vRegionalEnsembleRTMap{1}.regionalEnsembleRTStartLevel;
        VmMap{4,3}{1,6,RTPage} = inputData.vRegionalEnsembleRTMap{1}.regionalEnsembleRTEndLevel;
        VmMap{4,3}{1,7,RTPage} = inputData.vRegionalEnsembleRTMap{1}.regionalEnsembleRTLB;
        VmMap{4,3}{1,8,RTPage} = inputData.vRegionalEnsembleRTMap{1}.regionalEnsembleRTUB;
        VmMap{4,3}{1,9,RTPage} = inputData.vRegionalEnsembleRTMap{1}.regionalEnsembleRTPseudoDataTime;
        VmMap{4,3}{1,10,RTPage} = inputData.vRegionalEnsembleRTMap{1}.RTRegionalEnsembleDataSection;
        VmMap{4,3}{1,11,RTPage} = inputData.vRegionalEnsembleRTMap{1}.regionalEnsembleRTLocsStart;
        VmMap{4,3}{1,12,RTPage} = inputData.vRegionalEnsembleRTMap{1}.regionalEnsembleRTLocsEnd;
        VmMap{4,3}{1,13,RTPage} = inputData.vRegionalEnsembleRTMap{1}.regionalEnsembleRTMatrix;
        VmMap{4,3}{1,14,RTPage} = regionalEnsembleRTPksNum;
        
        RTPage = RTPage + 1;
    end
    
    
    if ~isempty( inputData.vGlobalSingleRTMap )
        
        label = inputData.vGlobalSingleRTMap{1}.globalSingleRTLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{4,3}{1,1,RTPage} = round(num1 * inputData.acqFreq);
        VmMap{4,3}{1,2,RTPage} = round(num2 * inputData.acqFreq);
        VmMap{4,3}{1,3,RTPage} = 'Global';
        VmMap{4,3}{1,4,RTPage} = 'Single';
        VmMap{4,3}{1,5,RTPage} = inputData.vGlobalSingleRTMap{1}.globalSingleRTStartLevel;
        VmMap{4,3}{1,6,RTPage} = inputData.vGlobalSingleRTMap{1}.globalSingleRTEndLevel;
        VmMap{4,3}{1,7,RTPage} = inputData.vGlobalSingleRTMap{1}.globalSingleRTLB;
        VmMap{4,3}{1,8,RTPage} = inputData.vGlobalSingleRTMap{1}.globalSingleRTUB;
        VmMap{4,3}{1,9,RTPage} = inputData.vGlobalSingleRTMap{1}.globalSingleRTPseudoDataTime;
        VmMap{4,3}{1,10,RTPage} = inputData.vGlobalSingleRTMap{1}.RTGlobalSingleDataSection;
        VmMap{4,3}{1,11,RTPage} = inputData.vGlobalSingleRTMap{1}.globalSingleRTLocsStart;
        VmMap{4,3}{1,12,RTPage} = inputData.vGlobalSingleRTMap{1}.globalSingleRTLocsEnd;
        VmMap{4,3}{1,13,RTPage} = inputData.vGlobalSingleRTMap{1}.globalSingleRTMatrix;
        VmMap{4,3}{1,14,RTPage} = [];
        
        RTPage = RTPage + 1;
    end
    
    if ~isempty( inputData.vGlobalEnsembleRTMap )
        
        label = inputData.vGlobalEnsembleRTMap{1}.globalEnsembleRTLabel;
        index = regexp(label, '\s');
        num1 = str2double( label( index(1) : index(2)-1 ) );
        num2 = str2double( label( index(2) : index(3) ) );
        
        VmMap{4,3}{1,1,RTPage} = round(num1 * inputData.acqFreq);
        VmMap{4,3}{1,2,RTPage} = round(num2 * inputData.acqFreq);
        VmMap{4,3}{1,3,RTPage} = 'Global';
        VmMap{4,3}{1,4,RTPage} = 'Ensemble';
        VmMap{4,3}{1,5,RTPage} = inputData.vGlobalEnsembleRTMap{1}.globalEnsembleRTStartLevel;
        VmMap{4,3}{1,6,RTPage} = inputData.vGlobalEnsembleRTMap{1}.globalEnsembleRTEndLevel;
        VmMap{4,3}{1,7,RTPage} = inputData.vGlobalEnsembleRTMap{1}.globalEnsembleRTLB;
        VmMap{4,3}{1,8,RTPage} = inputData.vGlobalEnsembleRTMap{1}.globalEnsembleRTUB;
        VmMap{4,3}{1,9,RTPage} = inputData.vGlobalEnsembleRTMap{1}.globalEnsembleRTPseudoDataTime;
        VmMap{4,3}{1,10,RTPage} = inputData.vGlobalEnsembleRTMap{1}.RTGlobalEnsembleDataSection;
        VmMap{4,3}{1,11,RTPage} = inputData.vGlobalEnsembleRTMap{1}.globalEnsembleRTLocsStart;
        VmMap{4,3}{1,12,RTPage} = inputData.vGlobalEnsembleRTMap{1}.globalEnsembleRTLocsEnd;
        VmMap{4,3}{1,13,RTPage} = inputData.vGlobalEnsembleRTMap{1}.globalEnsembleRTMatrix;
        VmMap{4,3}{1,14,RTPage} = globalEnsembleRTPksNum;
    end
    
    % If only single camera, then save the file
    if inputData.camTF == 0 % Single cameras
        
        cmosData1Raw = inputData.cmosData1Raw;
        cmosData1 = inputData.cmosData1;
        signalTime = inputData.signalTime;
        acqFreq = inputData.acqFreq;
        bgImage1 = inputData.bgImage1;
        bgImageNom1 = inputData.bgImageNom1;
        userMaskMatrix_cam1 = inputData.userMaskMatrix_cam1;
        analog1 = inputData.analog1;
        analog2 = inputData.analog2;
        analogTime = inputData.analogTime;
        pcl = inputData.pcl;
        camTF = inputData.camTF;
        fileInfo = inputData.fileInfo;
        signalConditioningInfo = inputData.signalConditioningInfo;
        comment = inputData.comment;
        
        VmMeasurement = { 'Camera1', VmMap }; % Camera 1
        CaMeasurement = { 'Camera1', CaMapEmpty }; % Camera 1
        
        save(fileName, 'cmosData1Raw', 'cmosData1', 'signalTime', 'acqFreq', 'bgImage1', 'bgImageNom1', 'userMaskMatrix_cam1', ...
            'analog1', 'analog2', 'analogTime', 'pcl', 'camTF', 'fileInfo', 'signalConditioningInfo', 'comment',...
            'VmMeasurement', 'CaMeasurement');
        
        % After saving, refresh inputData
        inputData = load(fileName);
    end
    
    if ishandle(f) == 1
        close(f)
    end
end



% ------------------------------------------------------------- %



% Check for dual cameras and re-arrange variables for camera 2 -----------------------
if inputData.camTF ~= 0 % Dual cameras
    
    field = { 'CaRegionalActMap', 'CaGlobalActMap', ...
        'CaRegionalRepMap', 'CaGlobalRepMap', ...
        'CaRegionalSingleRTMap', 'CaGlobalSingleRTMap', 'CaRegionalEnsembleRTMap', 'CaGlobalEnsembleRTMap', ...
        'regionalSingleCaTDMap', 'regionalEnsembleCaTDMap', 'globalSingleCaTDMap', 'globalEnsembleCaTDMap', ...
        'CaRegionalSingleDTMap', 'CaGlobalSingleDTMap', 'CaRegionalEnsembleDTMap', 'CaGlobalEnsembleDTMap', ...
        'CaRegionalSingleDTauMap', 'CaGlobalSingleDTauMap', 'CaRegionalEnsembleDTauMap', 'CaGlobalEnsembleDTauMap' };
    
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    % Need to migrate from old SliceZer to new version
    if TF == 1
        
        oldversionTF = 1; % Old version
        
        msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process.
        
        
        
        % Act map -----------------------
        actPage = 1;
        
        if ~isempty( inputData.CaRegionalActMap )
            
            label = inputData.CaRegionalActMap{1}.regionalActivationLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{1,3}{1,1,actPage} = round(num1 * inputData.acqFreq);
            CaMap{1,3}{1,2,actPage} = round(num2 * inputData.acqFreq);
            CaMap{1,3}{1,3,actPage} = 'Regional';
            CaMap{1,3}{1,4,actPage} = 'Single';
            CaMap{1,3}{1,5,actPage} = inputData.CaRegionalActMap{1}.regionalActLB;
            CaMap{1,3}{1,6,actPage} = inputData.CaRegionalActMap{1}.regionalActUB;
            CaMap{1,3}{1,7,actPage} = inputData.CaRegionalActMap{1}.regionalActPseudoDataTime;
            CaMap{1,3}{1,8,actPage} = inputData.CaRegionalActMap{1}.actRegionalDataSection;
            CaMap{1,3}{1,9,actPage} = inputData.CaRegionalActMap{1}.regionalActLocsAct;
            CaMap{1,3}{1,10,actPage} = inputData.CaRegionalActMap{1}.regionalRelativeActMatrix;
            CaMap{1,3}{1,11,actPage} = [];
            
            actPage = actPage + 1;
        end
        
        if ~isempty( inputData.CaGlobalActMap )
            
            label = inputData.CaGlobalActMap{1}.globalActivationLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{1,3}{1,1,actPage} = round(num1 * inputData.acqFreq);
            CaMap{1,3}{1,2,actPage} = round(num2 * inputData.acqFreq);
            CaMap{1,3}{1,3,actPage} = 'Global';
            CaMap{1,3}{1,4,actPage} = 'Single';
            CaMap{1,3}{1,5,actPage} = inputData.CaGlobalActMap{1}.globalActLB;
            CaMap{1,3}{1,6,actPage} = inputData.CaGlobalActMap{1}.globalActUB;
            CaMap{1,3}{1,7,actPage} = inputData.CaGlobalActMap{1}.globalActPseudoDataTime;
            CaMap{1,3}{1,8,actPage} = inputData.CaGlobalActMap{1}.actGlobalDataSection;
            CaMap{1,3}{1,9,actPage} = inputData.CaGlobalActMap{1}.globalActLocsAct;
            CaMap{1,3}{1,10,actPage} = inputData.CaGlobalActMap{1}.globalRelativeActMatrix;
            CaMap{1,3}{1,11,actPage} = [];
        end
        
        
        % Rep map -----------------------
        repPage = 1;
        
        if ~isempty( inputData.CaRegionalRepMap )
            
            label = inputData.CaRegionalRepMap{1}.RegionalRepolarisationLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{2,3}{1,1,repPage} = round(num1 * inputData.acqFreq);
            CaMap{2,3}{1,2,repPage} = round(num2 * inputData.acqFreq);
            CaMap{2,3}{1,3,repPage} = 'Regional';
            CaMap{2,3}{1,4,repPage} = 'Single';
            CaMap{2,3}{1,5,repPage} = inputData.CaRegionalRepMap{1}.regionalRepLevel;
            CaMap{2,3}{1,6,repPage} = inputData.CaRegionalRepMap{1}.regionalRepLB;
            CaMap{2,3}{1,7,repPage} = inputData.CaRegionalRepMap{1}.regionalRepUB;
            CaMap{2,3}{1,8,repPage} = inputData.CaRegionalRepMap{1}.regionalRepPseudoDataTime;
            CaMap{2,3}{1,9,repPage} = inputData.CaRegionalRepMap{1}.repRegionalDataSection;
            CaMap{2,3}{1,10,repPage} = inputData.CaRegionalRepMap{1}.regionalRepLocsRep;
            CaMap{2,3}{1,11,repPage} = inputData.CaRegionalRepMap{1}.regionalRelativeRepMatrix;
            CaMap{2,3}{1,12,repPage} = [];
            
            repPage = repPage + 1;
        end
        
        if ~isempty( inputData.CaGlobalRepMap )
            
            label = inputData.CaGlobalRepMap{1}.GlobalRepolarisationLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{2,3}{1,1,repPage} = round(num1 * inputData.acqFreq);
            CaMap{2,3}{1,2,repPage} = round(num2 * inputData.acqFreq);
            CaMap{2,3}{1,3,repPage} = 'Global';
            CaMap{2,3}{1,4,repPage} = 'Single';
            CaMap{2,3}{1,5,repPage} = inputData.CaGlobalRepMap{1}.globalRepLevel;
            CaMap{2,3}{1,6,repPage} = inputData.CaGlobalRepMap{1}.globalRepLB;
            CaMap{2,3}{1,7,repPage} = inputData.CaGlobalRepMap{1}.globalRepUB;
            CaMap{2,3}{1,8,repPage} = inputData.CaGlobalRepMap{1}.globalRepPseudoDataTime;
            CaMap{2,3}{1,9,repPage} = inputData.CaGlobalRepMap{1}.repGlobalDataSection;
            CaMap{2,3}{1,10,repPage} = inputData.CaGlobalRepMap{1}.globalRepLocsRep;
            CaMap{2,3}{1,11,repPage} = inputData.CaGlobalRepMap{1}.globalRelativeRepMatrix;
            CaMap{2,3}{1,12,repPage} = [];
        end
        
        
        % CaTD map -----------------------
        CaTDPage = 1;
        
        if ~isempty( inputData.regionalSingleCaTDMap )
            
            label = inputData.regionalSingleCaTDMap{1}.regionalSingleCaTDLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{3,3}{1,1,CaTDPage} = round(num1 * inputData.acqFreq);
            CaMap{3,3}{1,2,CaTDPage} = round(num2 * inputData.acqFreq);
            CaMap{3,3}{1,3,CaTDPage} = 'Regional';
            CaMap{3,3}{1,4,CaTDPage} = 'Single';
            CaMap{3,3}{1,5,CaTDPage} = inputData.regionalSingleCaTDMap{1}.regionalSingleCaTDRepLevel;
            CaMap{3,3}{1,6,CaTDPage} = inputData.regionalSingleCaTDMap{1}.regionalSingleCaTDLB;
            CaMap{3,3}{1,7,CaTDPage} = inputData.regionalSingleCaTDMap{1}.regionalSingleCaTDUB;
            CaMap{3,3}{1,8,CaTDPage} = inputData.regionalSingleCaTDMap{1}.regionalSingleCaTDPseudoDataTime;
            CaMap{3,3}{1,9,CaTDPage} = inputData.regionalSingleCaTDMap{1}.CaTDRegionalSingleDataSection;
            CaMap{3,3}{1,10,CaTDPage} = inputData.regionalSingleCaTDMap{1}.regionalSingleCaTDLocsAct;
            CaMap{3,3}{1,11,CaTDPage} = inputData.regionalSingleCaTDMap{1}.regionalSingleCaTDLocsRep;
            CaMap{3,3}{1,12,CaTDPage} = inputData.regionalSingleCaTDMap{1}.regionalSingleCaTDMatrix;
            CaMap{3,3}{1,13,CaTDPage} = [];
            
            CaTDPage = CaTDPage + 1;
        end
        
        if ~isempty( inputData.regionalEnsembleCaTDMap )
            
            label = inputData.regionalEnsembleCaTDMap{1}.regionalEnsembleCaTDLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{3,3}{1,1,CaTDPage} = round(num1 * inputData.acqFreq);
            CaMap{3,3}{1,2,CaTDPage} = round(num2 * inputData.acqFreq);
            CaMap{3,3}{1,3,CaTDPage} = 'Regional';
            CaMap{3,3}{1,4,CaTDPage} = 'Ensemble';
            CaMap{3,3}{1,5,CaTDPage} = inputData.regionalEnsembleCaTDMap{1}.regionalEnsembleCaTDRepLevel;
            CaMap{3,3}{1,6,CaTDPage} = inputData.regionalEnsembleCaTDMap{1}.regionalEnsembleCaTDLB;
            CaMap{3,3}{1,7,CaTDPage} = inputData.regionalEnsembleCaTDMap{1}.regionalEnsembleCaTDUB;
            CaMap{3,3}{1,8,CaTDPage} = inputData.regionalEnsembleCaTDMap{1}.regionalEnsembleCaTDPseudoDataTime;
            CaMap{3,3}{1,9,CaTDPage} = inputData.regionalEnsembleCaTDMap{1}.CaTDRegionalEnsembleDataSection;
            CaMap{3,3}{1,10,CaTDPage} = inputData.regionalEnsembleCaTDMap{1}.regionalEnsembleCaTDLocsAct;
            CaMap{3,3}{1,11,CaTDPage} = inputData.regionalEnsembleCaTDMap{1}.regionalEnsembleCaTDLocsRep;
            CaMap{3,3}{1,12,CaTDPage} = inputData.regionalEnsembleCaTDMap{1}.regionalEnsembleCaTDMatrix;
            CaMap{3,3}{1,13,CaTDPage} = inputData.regionalEnsembleCaTDMap{1}.regionalEnsembleCaTDPksNum;
            
            CaTDPage = CaTDPage + 1;
        end
        
        if ~isempty( inputData.globalSingleCaTDMap )
            
            label = inputData.globalSingleCaTDMap{1}.globalSingleCaTDLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{3,3}{1,1,CaTDPage} = round(num1 * inputData.acqFreq);
            CaMap{3,3}{1,2,CaTDPage} = round(num2 * inputData.acqFreq);
            CaMap{3,3}{1,3,CaTDPage} = 'Global';
            CaMap{3,3}{1,4,CaTDPage} = 'Single';
            CaMap{3,3}{1,5,CaTDPage} = inputData.globalSingleCaTDMap{1}.globalSingleCaTDRepLevel;
            CaMap{3,3}{1,6,CaTDPage} = inputData.globalSingleCaTDMap{1}.globalSingleCaTDLB;
            CaMap{3,3}{1,7,CaTDPage} = inputData.globalSingleCaTDMap{1}.globalSingleCaTDUB;
            CaMap{3,3}{1,8,CaTDPage} = inputData.globalSingleCaTDMap{1}.globalSingleCaTDPseudoDataTime;
            CaMap{3,3}{1,9,CaTDPage} = inputData.globalSingleCaTDMap{1}.CaTDGlobalSingleDataSection;
            CaMap{3,3}{1,10,CaTDPage} = inputData.globalSingleCaTDMap{1}.globalSingleCaTDLocsAct;
            CaMap{3,3}{1,11,CaTDPage} = inputData.globalSingleCaTDMap{1}.globalSingleCaTDLocsRep;
            CaMap{3,3}{1,12,CaTDPage} = inputData.globalSingleCaTDMap{1}.globalSingleCaTDMatrix;
            CaMap{3,3}{1,13,CaTDPage} = [];
            
            CaTDPage = CaTDPage + 1;
        end
        
        if ~isempty( inputData.globalEnsembleCaTDMap )
            
            label = inputData.globalEnsembleCaTDMap{1}.globalEnsembleCaTDLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{3,3}{1,1,CaTDPage} = round(num1 * inputData.acqFreq);
            CaMap{3,3}{1,2,CaTDPage} = round(num2 * inputData.acqFreq);
            CaMap{3,3}{1,3,CaTDPage} = 'Global';
            CaMap{3,3}{1,4,CaTDPage} = 'Ensemble';
            CaMap{3,3}{1,5,CaTDPage} = inputData.globalEnsembleCaTDMap{1}.globalEnsembleCaTDRepLevel;
            CaMap{3,3}{1,6,CaTDPage} = inputData.globalEnsembleCaTDMap{1}.globalEnsembleCaTDLB;
            CaMap{3,3}{1,7,CaTDPage} = inputData.globalEnsembleCaTDMap{1}.globalEnsembleCaTDUB;
            CaMap{3,3}{1,8,CaTDPage} = inputData.globalEnsembleCaTDMap{1}.globalEnsembleCaTDPseudoDataTime;
            CaMap{3,3}{1,9,CaTDPage} = inputData.globalEnsembleCaTDMap{1}.CaTDGlobalEnsembleDataSection;
            CaMap{3,3}{1,10,CaTDPage} = inputData.globalEnsembleCaTDMap{1}.globalEnsembleCaTDLocsAct;
            CaMap{3,3}{1,11,CaTDPage} = inputData.globalEnsembleCaTDMap{1}.globalEnsembleCaTDLocsRep;
            CaMap{3,3}{1,12,CaTDPage} = inputData.globalEnsembleCaTDMap{1}.globalEnsembleCaTDMatrix;
            CaMap{3,3}{1,13,CaTDPage} = inputData.globalEnsembleCaTDMap{1}.globalEnsembleCaTDPksNum;
        end
        
        
        % RT map -----------------------
        RTPage = 1;
        
        if ~isempty( inputData.CaRegionalSingleRTMap )
            
            label = inputData.CaRegionalSingleRTMap{1}.regionalSingleRTLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,RTPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,RTPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,RTPage} = 'Regional';
            CaMap{4,3}{1,4,RTPage} = 'Single';
            CaMap{4,3}{1,5,RTPage} = inputData.CaRegionalSingleRTMap{1}.regionalSingleRTStartLevel;
            CaMap{4,3}{1,6,RTPage} = inputData.CaRegionalSingleRTMap{1}.regionalSingleRTEndLevel;
            CaMap{4,3}{1,7,RTPage} = inputData.CaRegionalSingleRTMap{1}.regionalSingleRTLB;
            CaMap{4,3}{1,8,RTPage} = inputData.CaRegionalSingleRTMap{1}.regionalSingleRTUB;
            CaMap{4,3}{1,9,RTPage} = inputData.CaRegionalSingleRTMap{1}.regionalSingleRTPseudoDataTime;
            CaMap{4,3}{1,10,RTPage} = inputData.CaRegionalSingleRTMap{1}.RTRegionalSingleDataSection;
            CaMap{4,3}{1,11,RTPage} = inputData.CaRegionalSingleRTMap{1}.regionalSingleRTLocsStart;
            CaMap{4,3}{1,12,RTPage} = inputData.CaRegionalSingleRTMap{1}.regionalSingleRTLocsEnd;
            CaMap{4,3}{1,13,RTPage} = inputData.CaRegionalSingleRTMap{1}.regionalSingleRTMatrix;
            CaMap{4,3}{1,14,RTPage} = [];
            
            RTPage = RTPage + 1;
        end
        
        if ~isempty( inputData.CaRegionalEnsembleRTMap )
            
            label = inputData.CaRegionalEnsembleRTMap{1}.regionalEnsembleRTLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,RTPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,RTPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,RTPage} = 'Regional';
            CaMap{4,3}{1,4,RTPage} = 'Ensemble';
            CaMap{4,3}{1,5,RTPage} = inputData.CaRegionalEnsembleRTMap{1}.regionalEnsembleRTStartLevel;
            CaMap{4,3}{1,6,RTPage} = inputData.CaRegionalEnsembleRTMap{1}.regionalEnsembleRTEndLevel;
            CaMap{4,3}{1,7,RTPage} = inputData.CaRegionalEnsembleRTMap{1}.regionalEnsembleRTLB;
            CaMap{4,3}{1,8,RTPage} = inputData.CaRegionalEnsembleRTMap{1}.regionalEnsembleRTUB;
            CaMap{4,3}{1,9,RTPage} = inputData.CaRegionalEnsembleRTMap{1}.regionalEnsembleRTPseudoDataTime;
            CaMap{4,3}{1,10,RTPage} = inputData.CaRegionalEnsembleRTMap{1}.RTRegionalEnsembleDataSection;
            CaMap{4,3}{1,11,RTPage} = inputData.CaRegionalEnsembleRTMap{1}.regionalEnsembleRTLocsStart;
            CaMap{4,3}{1,12,RTPage} = inputData.CaRegionalEnsembleRTMap{1}.regionalEnsembleRTLocsEnd;
            CaMap{4,3}{1,13,RTPage} = inputData.CaRegionalEnsembleRTMap{1}.regionalEnsembleRTMatrix;
            CaMap{4,3}{1,14,RTPage} = regionalEnsembleRTPksNum;
            
            RTPage = RTPage + 1;
        end
        
        
        if ~isempty( inputData.CaGlobalSingleRTMap )
            
            label = inputData.CaGlobalSingleRTMap{1}.globalSingleRTLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,RTPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,RTPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,RTPage} = 'Global';
            CaMap{4,3}{1,4,RTPage} = 'Single';
            CaMap{4,3}{1,5,RTPage} = inputData.CaGlobalSingleRTMap{1}.globalSingleRTStartLevel;
            CaMap{4,3}{1,6,RTPage} = inputData.CaGlobalSingleRTMap{1}.globalSingleRTEndLevel;
            CaMap{4,3}{1,7,RTPage} = inputData.CaGlobalSingleRTMap{1}.globalSingleRTLB;
            CaMap{4,3}{1,8,RTPage} = inputData.CaGlobalSingleRTMap{1}.globalSingleRTUB;
            CaMap{4,3}{1,9,RTPage} = inputData.CaGlobalSingleRTMap{1}.globalSingleRTPseudoDataTime;
            CaMap{4,3}{1,10,RTPage} = inputData.CaGlobalSingleRTMap{1}.RTGlobalSingleDataSection;
            CaMap{4,3}{1,11,RTPage} = inputData.CaGlobalSingleRTMap{1}.globalSingleRTLocsStart;
            CaMap{4,3}{1,12,RTPage} = inputData.CaGlobalSingleRTMap{1}.globalSingleRTLocsEnd;
            CaMap{4,3}{1,13,RTPage} = inputData.CaGlobalSingleRTMap{1}.globalSingleRTMatrix;
            CaMap{4,3}{1,14,RTPage} = [];
            
            RTPage = RTPage + 1;
        end
        
        if ~isempty( inputData.CaGlobalEnsembleRTMap )
            
            label = inputData.CaGlobalEnsembleRTMap{1}.globalEnsembleRTLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,RTPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,RTPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,RTPage} = 'Global';
            CaMap{4,3}{1,4,RTPage} = 'Ensemble';
            CaMap{4,3}{1,5,RTPage} = inputData.CaGlobalEnsembleRTMap{1}.globalEnsembleRTStartLevel;
            CaMap{4,3}{1,6,RTPage} = inputData.CaGlobalEnsembleRTMap{1}.globalEnsembleRTEndLevel;
            CaMap{4,3}{1,7,RTPage} = inputData.CaGlobalEnsembleRTMap{1}.globalEnsembleRTLB;
            CaMap{4,3}{1,8,RTPage} = inputData.CaGlobalEnsembleRTMap{1}.globalEnsembleRTUB;
            CaMap{4,3}{1,9,RTPage} = inputData.CaGlobalEnsembleRTMap{1}.globalEnsembleRTPseudoDataTime;
            CaMap{4,3}{1,10,RTPage} = inputData.CaGlobalEnsembleRTMap{1}.RTGlobalEnsembleDataSection;
            CaMap{4,3}{1,11,RTPage} = inputData.CaGlobalEnsembleRTMap{1}.globalEnsembleRTLocsStart;
            CaMap{4,3}{1,12,RTPage} = inputData.CaGlobalEnsembleRTMap{1}.globalEnsembleRTLocsEnd;
            CaMap{4,3}{1,13,RTPage} = inputData.CaGlobalEnsembleRTMap{1}.globalEnsembleRTMatrix;
            CaMap{4,3}{1,14,RTPage} = globalEnsembleRTPksNum;
        end
        
        
        % DT map -----------------------
        DTPage = 1;
        
        if ~isempty( inputData.CaRegionalSingleDTMap )
            
            label = inputData.CaRegionalSingleDTMap{1}.regionalSingleDecayLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,DTPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,DTPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,DTPage} = 'Regional';
            CaMap{4,3}{1,4,DTPage} = 'Single';
            CaMap{4,3}{1,5,DTPage} = inputData.CaRegionalSingleDTMap{1}.regionalSingleDTStartLevel;
            CaMap{4,3}{1,6,DTPage} = inputData.CaRegionalSingleDTMap{1}.regionalSingleDTEndLevel;
            CaMap{4,3}{1,7,DTPage} = inputData.CaRegionalSingleDTMap{1}.regionalSingleDTLB;
            CaMap{4,3}{1,8,DTPage} = inputData.CaRegionalSingleDTMap{1}.regionalSingleDTUB;
            CaMap{4,3}{1,9,DTPage} = inputData.CaRegionalSingleDTMap{1}.regionalSingleDTPseudoDataTime;
            CaMap{4,3}{1,10,DTPage} = inputData.CaRegionalSingleDTMap{1}.DTRegionalSingleDataSection;
            CaMap{4,3}{1,11,DTPage} = inputData.CaRegionalSingleDTMap{1}.regionalSingleDTLocsStart;
            CaMap{4,3}{1,12,DTPage} = inputData.CaRegionalSingleDTMap{1}.regionalSingleDTLocsEnd;
            CaMap{4,3}{1,13,DTPage} = inputData.CaRegionalSingleDTMap{1}.regionalSingleDTMatrix;
            CaMap{4,3}{1,14,DTPage} = [];
            
            DTPage = DTPage + 1;
        end
        
        if ~isempty( inputData.CaRegionalEnsembleDTMap )
            
            label = inputData.CaRegionalEnsembleDTMap{1}.regionalEnsembleDecayLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,DTPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,DTPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,DTPage} = 'Regional';
            CaMap{4,3}{1,4,DTPage} = 'Ensemble';
            CaMap{4,3}{1,5,DTPage} = inputData.CaRegionalEnsembleDTMap{1}.regionalEnsembleDTStartLevel;
            CaMap{4,3}{1,6,DTPage} = inputData.CaRegionalEnsembleDTMap{1}.regionalEnsembleDTEndLevel;
            CaMap{4,3}{1,7,DTPage} = inputData.CaRegionalEnsembleDTMap{1}.regionalEnsembleDTLB;
            CaMap{4,3}{1,8,DTPage} = inputData.CaRegionalEnsembleDTMap{1}.regionalEnsembleDTUB;
            CaMap{4,3}{1,9,DTPage} = inputData.CaRegionalEnsembleDTMap{1}.regionalEnsembleDTPseudoDataTime;
            CaMap{4,3}{1,10,DTPage} = inputData.CaRegionalEnsembleDTMap{1}.DTRegionalEnsembleDataSection;
            CaMap{4,3}{1,11,DTPage} = inputData.CaRegionalEnsembleDTMap{1}.regionalEnsembleDTLocsStart;
            CaMap{4,3}{1,12,DTPage} = inputData.CaRegionalEnsembleDTMap{1}.regionalEnsembleDTLocsEnd;
            CaMap{4,3}{1,13,DTPage} = inputData.CaRegionalEnsembleDTMap{1}.regionalEnsembleDTMatrix;
            CaMap{4,3}{1,14,DTPage} = regionalEnsembleDTPksNum;
            
            DTPage = DTPage + 1;
        end
        
        
        if ~isempty( inputData.CaGlobalSingleDTMap )
            
            label = inputData.CaGlobalSingleDTMap{1}.globalSingleDecayLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,DTPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,DTPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,DTPage} = 'Global';
            CaMap{4,3}{1,4,DTPage} = 'Single';
            CaMap{4,3}{1,5,DTPage} = inputData.CaGlobalSingleDTMap{1}.globalSingleDTStartLevel;
            CaMap{4,3}{1,6,DTPage} = inputData.CaGlobalSingleDTMap{1}.globalSingleDTEndLevel;
            CaMap{4,3}{1,7,DTPage} = inputData.CaGlobalSingleDTMap{1}.globalSingleDTLB;
            CaMap{4,3}{1,8,DTPage} = inputData.CaGlobalSingleDTMap{1}.globalSingleDTUB;
            CaMap{4,3}{1,9,DTPage} = inputData.CaGlobalSingleDTMap{1}.globalSingleDTPseudoDataTime;
            CaMap{4,3}{1,10,DTPage} = inputData.CaGlobalSingleDTMap{1}.DTGlobalSingleDataSection;
            CaMap{4,3}{1,11,DTPage} = inputData.CaGlobalSingleDTMap{1}.globalSingleDTLocsStart;
            CaMap{4,3}{1,12,DTPage} = inputData.CaGlobalSingleDTMap{1}.globalSingleDTLocsEnd;
            CaMap{4,3}{1,13,DTPage} = inputData.CaGlobalSingleDTMap{1}.globalSingleDTMatrix;
            CaMap{4,3}{1,14,DTPage} = [];
            
            DTPage = DTPage + 1;
        end
        
        if ~isempty( inputData.CaGlobalEnsembleDTMap )
            
            label = inputData.CaGlobalEnsembleDTMap{1}.globalEnsembleDecayLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,DTPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,DTPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,DTPage} = 'Global';
            CaMap{4,3}{1,4,DTPage} = 'Ensemble';
            CaMap{4,3}{1,5,DTPage} = inputData.CaGlobalEnsembleDTMap{1}.globalEnsembleDTStartLevel;
            CaMap{4,3}{1,6,DTPage} = inputData.CaGlobalEnsembleDTMap{1}.globalEnsembleDTEndLevel;
            CaMap{4,3}{1,7,DTPage} = inputData.CaGlobalEnsembleDTMap{1}.globalEnsembleDTLB;
            CaMap{4,3}{1,8,DTPage} = inputData.CaGlobalEnsembleDTMap{1}.globalEnsembleDTUB;
            CaMap{4,3}{1,9,DTPage} = inputData.CaGlobalEnsembleDTMap{1}.globalEnsembleDTPseudoDataTime;
            CaMap{4,3}{1,10,DTPage} = inputData.CaGlobalEnsembleDTMap{1}.DTGlobalEnsembleDataSection;
            CaMap{4,3}{1,11,DTPage} = inputData.CaGlobalEnsembleDTMap{1}.globalEnsembleDTLocsStart;
            CaMap{4,3}{1,12,DTPage} = inputData.CaGlobalEnsembleDTMap{1}.globalEnsembleDTLocsEnd;
            CaMap{4,3}{1,13,DTPage} = inputData.CaGlobalEnsembleDTMap{1}.globalEnsembleDTMatrix;
            CaMap{4,3}{1,14,DTPage} = globalEnsembleDTPksNum;
        end
        
        
        % DTau map -----------------------
        DTauPage = 1;
        
        if ~isempty( inputData.CaRegionalSingleDTauMap )
            
            label = inputData.CaRegionalSingleDTauMap{1}.regionalSingleDecayLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,DTauPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,DTauPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,DTauPage} = 'Regional';
            CaMap{4,3}{1,4,DTauPage} = 'Single';
            CaMap{4,3}{1,5,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.regionalSingleDTauStartLevel;
            CaMap{4,3}{1,6,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.regionalSingleDTauEndLevel;
            CaMap{4,3}{1,7,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.regionalSingleDTauLB;
            CaMap{4,3}{1,8,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.regionalSingleDTauUB;
            CaMap{4,3}{1,9,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.regionalSingleDTauPseudoDataTime;
            CaMap{4,3}{1,10,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.DTauRegionalSingleDataSection;
            CaMap{4,3}{1,11,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.DTauRegionalSingleFitData;
            CaMap{4,3}{1,12,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.regionalSingleDTauLocsStart;
            CaMap{4,3}{1,13,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.regionalSingleDTauLocsEnd;
            CaMap{4,3}{1,14,DTauPage} = inputData.CaRegionalSingleDTauMap{1}.regionalSingleDTauMatrix;
            CaMap{4,3}{1,15,DTauPage} = [];
            
            DTauPage = DTauPage + 1;
        end
        
        if ~isempty( inputData.CaRegionalEnsembleDTauMap )
            
            label = inputData.CaRegionalEnsembleDTauMap{1}.regionalEnsembleDecayLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,DTauPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,DTauPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,DTauPage} = 'Regional';
            CaMap{4,3}{1,4,DTauPage} = 'Ensemble';
            CaMap{4,3}{1,5,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.regionalEnsembleDTauStartLevel;
            CaMap{4,3}{1,6,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.regionalEnsembleDTauEndLevel;
            CaMap{4,3}{1,7,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.regionalEnsembleDTauLB;
            CaMap{4,3}{1,8,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.regionalEnsembleDTauUB;
            CaMap{4,3}{1,9,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.regionalEnsembleDTauPseudoDataTime;
            CaMap{4,3}{1,10,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.DTauRegionalEnsembleDataSection;
            CaMap{4,3}{1,11,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.DTauRegionalEnsembleFitData;
            CaMap{4,3}{1,12,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.regionalEnsembleDTauLocsStart;
            CaMap{4,3}{1,13,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.regionalEnsembleDTauLocsEnd;
            CaMap{4,3}{1,14,DTauPage} = inputData.CaRegionalEnsembleDTauMap{1}.regionalEnsembleDTauMatrix;
            CaMap{4,3}{1,15,DTauPage} = regionalEnsembleDTauPksNum;
            
            DTauPage = DTauPage + 1;
        end
        
        
        if ~isempty( inputData.CaGlobalSingleDTauMap )
            
            label = inputData.CaGlobalSingleDTauMap{1}.globalSingleDecayLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,DTauPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,DTauPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,DTauPage} = 'Global';
            CaMap{4,3}{1,4,DTauPage} = 'Single';
            CaMap{4,3}{1,5,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.globalSingleDTauStartLevel;
            CaMap{4,3}{1,6,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.globalSingleDTauEndLevel;
            CaMap{4,3}{1,7,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.globalSingleDTauLB;
            CaMap{4,3}{1,8,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.globalSingleDTauUB;
            CaMap{4,3}{1,9,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.globalSingleDTauPseudoDataTime;
            CaMap{4,3}{1,10,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.DTauGlobalSingleDataSection;
            CaMap{4,3}{1,11,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.DTauGlobalSingleFitData;
            CaMap{4,3}{1,12,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.globalSingleDTauLocsStart;
            CaMap{4,3}{1,13,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.globalSingleDTauLocsEnd;
            CaMap{4,3}{1,14,DTauPage} = inputData.CaGlobalSingleDTauMap{1}.globalSingleDTauMatrix;
            CaMap{4,3}{1,15,DTauPage} = [];
            
            DTauPage = DTauPage + 1;
        end
        
        if ~isempty( inputData.CaGlobalEnsembleDTauMap )
            
            label = inputData.CaGlobalEnsembleDTauMap{1}.globalEnsembleDecayLabel;
            index = regexp(label, '\s');
            num1 = str2double( label( index(1) : index(2)-1 ) );
            num2 = str2double( label( index(2) : index(3) ) );
            
            CaMap{4,3}{1,1,DTauPage} = round(num1 * inputData.acqFreq);
            CaMap{4,3}{1,2,DTauPage} = round(num2 * inputData.acqFreq);
            CaMap{4,3}{1,3,DTauPage} = 'Global';
            CaMap{4,3}{1,4,DTauPage} = 'Ensemble';
            CaMap{4,3}{1,5,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.globalEnsembleDTauStartLevel;
            CaMap{4,3}{1,6,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.globalEnsembleDTauEndLevel;
            CaMap{4,3}{1,7,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.globalEnsembleDTauLB;
            CaMap{4,3}{1,8,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.globalEnsembleDTauUB;
            CaMap{4,3}{1,9,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.globalEnsembleDTauPseudoDataTime;
            CaMap{4,3}{1,10,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.DTauGlobalEnsembleDataSection;
            CaMap{4,3}{1,11,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.DTauGlobalEnsembleFitData;
            CaMap{4,3}{1,12,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.globalEnsembleDTauLocsStart;
            CaMap{4,3}{1,13,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.globalEnsembleDTauLocsEnd;
            CaMap{4,3}{1,14,DTauPage} = inputData.CaGlobalEnsembleDTauMap{1}.globalEnsembleDTauMatrix;
            CaMap{4,3}{1,15,DTauPage} = globalEnsembleDTauPksNum;
        end
        
        % Save the file
        cmosData1Raw = inputData.cmosData1Raw;
        cmosData1 = inputData.cmosData1;
        cmosData2Raw = inputData.cmosData2Raw;
        cmosData2 = inputData.cmosData2;
        signalTime = inputData.signalTime;
        acqFreq = inputData.acqFreq;
        bgImage1 = inputData.bgImage1;
        bgImageNom1 = inputData.bgImageNom1;
        bgImage2 = inputData.bgImage2;
        bgImageNom2 = inputData.bgImageNom2;
        userMaskMatrix_cam1 = inputData.userMaskMatrix_cam1;
        userMaskMatrix_cam2 = inputData.userMaskMatrix_cam2;
        analog1 = inputData.analog1;
        analog2 = inputData.analog2;
        analogTime = inputData.analogTime;
        pcl = inputData.pcl;
        camTF = inputData.camTF;
        fileInfo = inputData.fileInfo;
        signalConditioningInfo = inputData.signalConditioningInfo;
        comment = inputData.comment;
        
        VmMeasurement = { 'Camera1', VmMap; 'Camera2', VmMapEmpty }; % Camera 1; Camera 2
        CaMeasurement = { 'Camera1', CaMapEmpty; 'Camera2', CaMap }; % Camera 1; Camera 2
        
        save(fileName, 'cmosData1Raw', 'cmosData1', 'cmosData2Raw', 'cmosData2', 'signalTime', 'acqFreq', 'bgImage1', 'bgImageNom1', 'bgImage2', 'bgImageNom2', 'userMaskMatrix_cam1', 'userMaskMatrix_cam2', ...
            'analog1', 'analog2', 'analogTime', 'pcl', 'camTF', 'fileInfo', 'signalConditioningInfo', 'comment',...
            'VmMeasurement', 'CaMeasurement');
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        if ishandle(f) == 1
            close(f)
        end
    end
end






%% ------------------------------------------------------------- %
% Version Check Type II
sectionID = 2;

% Re-Arrange Variables for Single Camera Files -----------------------
if inputData.camTF == 0 % Single cameras
    
    field = { 'VmMap' };
    
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    % Need to migrate from old SliceZer to new version
    if TF == 1
        
        oldversionTF = 1; % Old version
        
        msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
        
        VmMeasurement = { 'Camera1', inputData.VmMap }; % Camera 1
        CaMeasurement = { 'Camera1', CaMapEmpty }; % Camera 1
        
        cmosData1Raw = inputData.cmosData1Raw;
        cmosData1 = inputData.cmosData1;
        signalTime = inputData.signalTime;
        acqFreq = inputData.acqFreq;
        bgImage1 = inputData.bgImage1;
        bgImageNom1 = inputData.bgImageNom1;
        userMaskMatrix_cam1 = inputData.userMaskMatrix_cam1;
        analog1 = inputData.analog1;
        analog2 = inputData.analog2;
        analogTime = inputData.analogTime;
        pcl = inputData.pcl;
        camTF = inputData.camTF;
        fileInfo = inputData.fileInfo;
        signalConditioningInfo = inputData.signalConditioningInfo;
        comment = inputData.comment;
        
        save(fileName, 'cmosData1Raw', 'cmosData1', 'signalTime', 'acqFreq', 'bgImage1', 'bgImageNom1', 'userMaskMatrix_cam1', ...
            'analog1', 'analog2', 'analogTime', 'pcl', 'camTF', 'fileInfo', 'signalConditioningInfo', 'comment',...
            'VmMeasurement', 'CaMeasurement');
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        if ishandle(f) == 1
            close(f)
        end
    end
    
    
else % Re-Arrange Variables for Dual Camera Files -----------------------
    
    field = { 'VmMap', 'CaMap' };
    
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    % Need to migrate from old SliceZer to new version
    if TF == 1
        
        oldversionTF = 1; % Old version
        
        msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
        
        VmMeasurement = { 'Camera1', inputData.VmMap; 'Camera2', VmMapEmpty }; % Camera 1; Camera 2
        CaMeasurement = { 'Camera1', CaMapEmpty; 'Camera2', inputData.CaMap }; % Camera 1; Camera 2
        
        cmosData1Raw = inputData.cmosData1Raw;
        cmosData1 = inputData.cmosData1;
        cmosData2Raw = inputData.cmosData2Raw;
        cmosData2 = inputData.cmosData2;
        signalTime = inputData.signalTime;
        acqFreq = inputData.acqFreq;
        bgImage1 = inputData.bgImage1;
        bgImageNom1 = inputData.bgImageNom1;
        bgImage2 = inputData.bgImage2;
        bgImageNom2 = inputData.bgImageNom2;
        userMaskMatrix_cam1 = inputData.userMaskMatrix_cam1;
        userMaskMatrix_cam2 = inputData.userMaskMatrix_cam2;
        analog1 = inputData.analog1;
        analog2 = inputData.analog2;
        analogTime = inputData.analogTime;
        pcl = inputData.pcl;
        camTF = inputData.camTF;
        fileInfo = inputData.fileInfo;
        signalConditioningInfo = inputData.signalConditioningInfo;
        comment = inputData.comment;
        
        save(fileName, 'cmosData1Raw', 'cmosData1', 'cmosData2Raw', 'cmosData2', 'signalTime', 'acqFreq', 'bgImage1', 'bgImageNom1', 'bgImage2', 'bgImageNom2', 'userMaskMatrix_cam1', 'userMaskMatrix_cam2', ...
            'analog1', 'analog2', 'analogTime', 'pcl', 'camTF', 'fileInfo', 'signalConditioningInfo', 'comment',...
            'VmMeasurement', 'CaMeasurement');
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        if ishandle(f) == 1
            close(f)
        end
    end
    
end






%% ------------------------------------------------------------- %
% Version Check Type III - pacing signals
sectionID = 3;

acqFreq = inputData.acqFreq;
pcl = inputData.pcl;

analog1_check = inputData.analog1;
analog2_check = inputData.analog2;


if sum( analog1_check ) > 0 % analog1 has pacing signals
    
    % Narrow analog1 pacing spikes (i.e., [0,1,1,0] --> [0,1,0,0])
    pcl_DataPoints = round( pcl / (1000 / acqFreq) );
    scanRange = round( 0.8 * pcl_DataPoints );
    
    for ID = 1 : length(analog1_check)-2
        
        if ( analog1_check(ID) == 0 )  &&  ( analog1_check(ID+1) == 1 )  &&  ( analog1_check(ID+2) == 1 )
            
            if ID + 2 + scanRange <= length(analog1_check)
                
                analog1_check(ID + 2  :  ID + 2 + scanRange) = 0;
                
            elseif ID + 2 <= length(analog1_check)  &&  ID + 2 + scanRange > length(analog1_check)
                
                analog1_check(ID + 2  :  end) = 0;
                break
            end
        end
    end
    
    if ~isequal( analog1_check, inputData.analog1 )
        TF1 = 1; % Need to migrate from old SliceZer to new version
    else
        TF1 = 0;
    end
    
else % analog1 has no pacing signals
    TF1 = 0;
end


if sum( analog2_check ) > 0 % analog1 has pacing signals
    
    % Narrow analog2 pacing spikes (i.e., [0,1,1,0] --> [0,1,0,0])
    pcl_DataPoints = round( pcl / (1000 / acqFreq) );
    scanRange = round( 0.8 * pcl_DataPoints );
    
    for ID = 1 : length(analog2_check)-2
        
        if ( analog2_check(ID) == 0 )  &&  ( analog2_check(ID+1) == 1 )  &&  ( analog2_check(ID+2) == 1 )
            
            if ID + 2 + scanRange <= length(analog2_check)
                
                analog2_check(ID + 2  :  ID + 2 + scanRange) = 0;
                
            elseif ID + 2 <= length(analog2_check)  &&  ID + 2 + scanRange > length(analog2_check)
                
                analog2_check(ID + 2  :  end) = 0;
                break
            end
        end
    end
    
    if ~isequal( analog2_check, inputData.analog2 )
        TF2 = 1; % Need to migrate from old SliceZer to new version
    else
        TF2 = 0;
    end
    
else % analog2 has pacing signals
    TF2 = 0;
end



if TF1 + TF2 ~= 0 % Need to migrate from old SliceZer to new version
    
    oldversionTF = 1; % Old version
    
    msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
    f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
    
    % Re-Arrange Variables for Single Camera Files -----------------------
    if inputData.camTF == 0 % Single cameras
        
        analog1 = analog1_check;
        analog2 = analog2_check;
        
        save(fileName, 'analog1', 'analog2',  '-append');
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        
        
    else % Re-Arrange Variables for Dual Camera Files -----------------------
        
        analog1 = analog1_check;
        analog2 = analog2_check;
        
        save(fileName, 'analog1', 'analog2',  '-append');
        
        % After saving, refresh inputData
        inputData = load(fileName);
    end
    
    if ishandle(f) == 1
        close(f)
    end
end









%% ------------------------------------------------------------- %
% Version Check Type IV - Update the number of maps that can be saved
sectionID = 4;

% Re-Arrange Variables for Single Camera Files -----------------------
if inputData.camTF == 0 % Single cameras
    
    field = { 'VmMeasurement', 'CaMeasurement' };
    
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    page1 = size( inputData.VmMeasurement{1,2}{1,3}, 3 );
    page2 = size( inputData.CaMeasurement{1,2}{1,3}, 3 );
    oldDataPage = min( [ page1, page2 ] );
    newDataPage = maxFileNum;
    
    pageTF = oldDataPage < newDataPage;
    
    % Need to migrate from old SliceZer to new version
    if ( TF == 1 )  &&  ( pageTF == 1 )
        
        oldversionTF = 1; % Old version
        
        msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
        
        % Camera 1 Vm
        for ID = 1 : size(VmMap,1) % Act, Rep, APD,  RT
            
            mapTemporary = VmMap{ID,3}; % ActMapData, RepMapData, APDMapData, RTMapData
            
            if ID == 1 % Act
                
                old_Vm_ActVarNum = size( inputData.VmMeasurement{1,2}{1,3}, 2 ); % The number of parameters inside Act Map
                newActVarNum = 11;
                
                if old_Vm_ActVarNum ~= newActVarNum
                    
                    old_ActMapData = inputData.VmMeasurement{1,2}{1,3};
                    actNum = 0;
                    for checkID = 1 : oldDataPage
                        actNum = actNum + ~isempty( old_ActMapData{1,1,checkID} ); % The number of actMap the user has stored
                    end
                    
                    if actNum ~= 0
                        for actID = 1 : actNum % Act
                            mapTemporary{1,1,actID} = old_ActMapData{1,1,actID};
                            mapTemporary{1,2,actID} = old_ActMapData{1,2,actID};
                            mapTemporary{1,3,actID} = old_ActMapData{1,3,actID};
                            mapTemporary{1,4,actID} = 'Single';
                            mapTemporary{1,5,actID} = old_ActMapData{1,4,actID};
                            mapTemporary{1,6,actID} = old_ActMapData{1,5,actID};
                            mapTemporary{1,7,actID} = old_ActMapData{1,6,actID};
                            mapTemporary{1,8,actID} = old_ActMapData{1,7,actID};
                            mapTemporary{1,9,actID} = old_ActMapData{1,8,actID};
                            mapTemporary{1,10,actID} = old_ActMapData{1,9,actID};
                            mapTemporary{1,11,actID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.VmMeasurement{1,2}{1,3}(:,:, 1:oldDataPage);
                end
                
                
            elseif ID == 2 % Rep
                
                old_Vm_RepVarNum = size( inputData.VmMeasurement{1,2}{2,3}, 2 );
                newRepVarNum = 12;
                
                if old_Vm_RepVarNum ~= newRepVarNum
                    
                    old_RepMapData = inputData.VmMeasurement{1,2}{2,3};
                    repNum = 0;
                    for checkID = 1 : oldDataPage
                        repNum = repNum + ~isempty( old_RepMapData{1,1,checkID} ); % The number of repMap the user has stored
                    end
                    
                    if repNum ~= 0
                        for repID = 1 : repNum % Rep
                            mapTemporary{1,1,repID} = old_RepMapData{1,1,repID};
                            mapTemporary{1,2,repID} = old_RepMapData{1,2,repID};
                            mapTemporary{1,3,repID} = old_RepMapData{1,3,repID};
                            mapTemporary{1,4,repID} = 'Single';
                            mapTemporary{1,5,repID} = old_RepMapData{1,4,repID};
                            mapTemporary{1,6,repID} = old_RepMapData{1,5,repID};
                            mapTemporary{1,7,repID} = old_RepMapData{1,6,repID};
                            mapTemporary{1,8,repID} = old_RepMapData{1,7,repID};
                            mapTemporary{1,9,repID} = old_RepMapData{1,8,repID};
                            mapTemporary{1,10,repID} = old_RepMapData{1,9,repID};
                            mapTemporary{1,11,repID} = old_RepMapData{1,10,repID};
                            mapTemporary{1,12,repID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.VmMeasurement{1,2}{2,3}(:,:, 1:oldDataPage);
                end
                
                
            else
                mapTemporary(:,:, 1:oldDataPage) = inputData.VmMeasurement{1,2}{ID,3}(:,:, 1:oldDataPage);
            end
            
            VmMap{ID,3} = mapTemporary;
        end
        
        % Camera 1 Ca
        for ID = 1 : size(CaMap,1) % Act, Rep, CaTD,  RT, DT, DTau
            
            mapTemporary = CaMap{ID,3}; % ActMapData, RepMapData, CaTDMapData, RTMapData, DTMapData, DTauMapData
            
            if ID == 1 % Act
                
                old_Ca_ActVarNum = size( inputData.CaMeasurement{1,2}{1,3}, 2 ); % The number of parameters inside Act Map
                newActVarNum = 11;
                
                if old_Ca_ActVarNum ~= newActVarNum
                    
                    old_ActMapData = inputData.CaMeasurement{1,2}{1,3};
                    actNum = 0;
                    for checkID = 1 : oldDataPage
                        actNum = actNum + ~isempty( old_ActMapData{1,1,checkID} ); % The number of actMap the user has stored
                    end
                    
                    if actNum ~= 0
                        for actID = 1 : actNum % Act
                            mapTemporary{1,1,actID} = old_ActMapData{1,1,actID};
                            mapTemporary{1,2,actID} = old_ActMapData{1,2,actID};
                            mapTemporary{1,3,actID} = old_ActMapData{1,3,actID};
                            mapTemporary{1,4,actID} = 'Single';
                            mapTemporary{1,5,actID} = old_ActMapData{1,4,actID};
                            mapTemporary{1,6,actID} = old_ActMapData{1,5,actID};
                            mapTemporary{1,7,actID} = old_ActMapData{1,6,actID};
                            mapTemporary{1,8,actID} = old_ActMapData{1,7,actID};
                            mapTemporary{1,9,actID} = old_ActMapData{1,8,actID};
                            mapTemporary{1,10,actID} = old_ActMapData{1,9,actID};
                            mapTemporary{1,11,actID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.CaMeasurement{1,2}{1,3}(:,:, 1:oldDataPage);
                end
                
                
            elseif ID == 2 % Rep
                
                old_Ca_RepVarNum = size( inputData.CaMeasurement{1,2}{2,3}, 2 );
                newRepVarNum = 12;
                
                if old_Ca_RepVarNum ~= newRepVarNum
                    
                    old_RepMapData = inputData.CaMeasurement{1,2}{2,3};
                    repNum = 0;
                    for checkID = 1 : oldDataPage
                        repNum = repNum + ~isempty( old_RepMapData{1,1,checkID} ); % The number of repMap the user has stored
                    end
                    
                    if repNum ~= 0
                        for repID = 1 : repNum % Rep
                            mapTemporary{1,1,repID} = old_RepMapData{1,1,repID};
                            mapTemporary{1,2,repID} = old_RepMapData{1,2,repID};
                            mapTemporary{1,3,repID} = old_RepMapData{1,3,repID};
                            mapTemporary{1,4,repID} = 'Single';
                            mapTemporary{1,5,repID} = old_RepMapData{1,4,repID};
                            mapTemporary{1,6,repID} = old_RepMapData{1,5,repID};
                            mapTemporary{1,7,repID} = old_RepMapData{1,6,repID};
                            mapTemporary{1,8,repID} = old_RepMapData{1,7,repID};
                            mapTemporary{1,9,repID} = old_RepMapData{1,8,repID};
                            mapTemporary{1,10,repID} = old_RepMapData{1,9,repID};
                            mapTemporary{1,11,repID} = old_RepMapData{1,10,repID};
                            mapTemporary{1,12,repID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.CaMeasurement{1,2}{2,3}(:,:, 1:oldDataPage);
                end
                
                
            else
                mapTemporary(:,:, 1:oldDataPage) = inputData.CaMeasurement{1,2}{ID,3}(:,:, 1:oldDataPage);
            end
            
            CaMap{ID,3} = mapTemporary;
        end
        
        VmMeasurement = { 'Camera1', VmMap }; % Camera 1
        CaMeasurement = { 'Camera1', CaMap }; % Camera 1
        
        save(fileName, 'VmMeasurement', 'CaMeasurement',  '-append');
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        if ishandle(f) == 1
            close(f)
        end
    end
    
    
else % Re-Arrange Variables for Dual Camera Files -----------------------
    
    field = { 'VmMeasurement', 'CaMeasurement' };
    
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    page1 = size( inputData.VmMeasurement{1,2}{1,3}, 3 );
    page2 = size( inputData.VmMeasurement{2,2}{1,3}, 3 );
    page3 = size( inputData.CaMeasurement{1,2}{1,3}, 3 );
    page4 = size( inputData.CaMeasurement{2,2}{1,3}, 3 );
    oldDataPage = min( [ page1, page2, page3, page4 ] );
    newDataPage = maxFileNum;
    
    pageTF = oldDataPage < newDataPage;
    
    % Need to migrate from old SliceZer to new version
    if ( TF == 1 )  &&  ( pageTF == 1 )
        
        oldversionTF = 1; % Old version
        
        msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
        
        VmMap_1 = VmMap;
        VmMap_2 = VmMap;
        
        CaMap_1 = CaMap;
        CaMap_2 = CaMap;
        
        % Camera 1 Vm ---------
        for ID = 1 : size(VmMap_1,1) % Act, Rep, APD,  RT
            
            mapTemporary = VmMap_1{ID,3}; % ActMapData, RepMapData, APDMapData, RTMapData
            
            if ID == 1 % Act
                
                old_Vm_ActVarNum = size( inputData.VmMeasurement{1,2}{1,3}, 2 ); % The number of parameters inside Act Map
                newActVarNum = 11;
                
                if old_Vm_ActVarNum ~= newActVarNum
                    
                    old_ActMapData = inputData.VmMeasurement{1,2}{1,3};
                    actNum = 0;
                    for checkID = 1 : oldDataPage
                        actNum = actNum + ~isempty( old_ActMapData{1,1,checkID} ); % The number of actMap the user has stored
                    end
                    
                    if actNum ~= 0
                        for actID = 1 : actNum % Act
                            mapTemporary{1,1,actID} = old_ActMapData{1,1,actID};
                            mapTemporary{1,2,actID} = old_ActMapData{1,2,actID};
                            mapTemporary{1,3,actID} = old_ActMapData{1,3,actID};
                            mapTemporary{1,4,actID} = 'Single';
                            mapTemporary{1,5,actID} = old_ActMapData{1,4,actID};
                            mapTemporary{1,6,actID} = old_ActMapData{1,5,actID};
                            mapTemporary{1,7,actID} = old_ActMapData{1,6,actID};
                            mapTemporary{1,8,actID} = old_ActMapData{1,7,actID};
                            mapTemporary{1,9,actID} = old_ActMapData{1,8,actID};
                            mapTemporary{1,10,actID} = old_ActMapData{1,9,actID};
                            mapTemporary{1,11,actID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.VmMeasurement{1,2}{1,3}(:,:, 1:oldDataPage);
                end
                
                
            elseif ID == 2 % Rep
                
                old_Vm_RepVarNum = size( inputData.VmMeasurement{1,2}{2,3}, 2 );
                newRepVarNum = 12;
                
                if old_Vm_RepVarNum ~= newRepVarNum
                    
                    old_RepMapData = inputData.VmMeasurement{1,2}{2,3};
                    repNum = 0;
                    for checkID = 1 : oldDataPage
                        repNum = repNum + ~isempty( old_RepMapData{1,1,checkID} ); % The number of repMap the user has stored
                    end
                    
                    if repNum ~= 0
                        for repID = 1 : repNum % Rep
                            mapTemporary{1,1,repID} = old_RepMapData{1,1,repID};
                            mapTemporary{1,2,repID} = old_RepMapData{1,2,repID};
                            mapTemporary{1,3,repID} = old_RepMapData{1,3,repID};
                            mapTemporary{1,4,repID} = 'Single';
                            mapTemporary{1,5,repID} = old_RepMapData{1,4,repID};
                            mapTemporary{1,6,repID} = old_RepMapData{1,5,repID};
                            mapTemporary{1,7,repID} = old_RepMapData{1,6,repID};
                            mapTemporary{1,8,repID} = old_RepMapData{1,7,repID};
                            mapTemporary{1,9,repID} = old_RepMapData{1,8,repID};
                            mapTemporary{1,10,repID} = old_RepMapData{1,9,repID};
                            mapTemporary{1,11,repID} = old_RepMapData{1,10,repID};
                            mapTemporary{1,12,repID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.VmMeasurement{1,2}{2,3}(:,:, 1:oldDataPage);
                end
                
                
            else
                mapTemporary(:,:, 1:oldDataPage) = inputData.VmMeasurement{1,2}{ID,3}(:,:, 1:oldDataPage);
            end
            
            VmMap_1{ID,3} = mapTemporary;
        end
        
        % Camera 1 Ca ---------
        for ID = 1 : size(CaMap_1,1) % Act, Rep, CaTD,  RT, DT, DTau
            
            mapTemporary = CaMap_1{ID,3}; % ActMapData, RepMapData, CaTDMapData, RTMapData, DTMapData, DTauMapData
            
            if ID == 1 % Act
                
                old_Ca_ActVarNum = size( inputData.CaMeasurement{1,2}{1,3}, 2 ); % The number of parameters inside Act Map
                newActVarNum = 11;
                
                if old_Ca_ActVarNum ~= newActVarNum
                    
                    old_ActMapData = inputData.CaMeasurement{1,2}{1,3};
                    actNum = 0;
                    for checkID = 1 : oldDataPage
                        actNum = actNum + ~isempty( old_ActMapData{1,1,checkID} ); % The number of actMap the user has stored
                    end
                    
                    if actNum ~= 0
                        for actID = 1 : actNum % Act
                            mapTemporary{1,1,actID} = old_ActMapData{1,1,actID};
                            mapTemporary{1,2,actID} = old_ActMapData{1,2,actID};
                            mapTemporary{1,3,actID} = old_ActMapData{1,3,actID};
                            mapTemporary{1,4,actID} = 'Single';
                            mapTemporary{1,5,actID} = old_ActMapData{1,4,actID};
                            mapTemporary{1,6,actID} = old_ActMapData{1,5,actID};
                            mapTemporary{1,7,actID} = old_ActMapData{1,6,actID};
                            mapTemporary{1,8,actID} = old_ActMapData{1,7,actID};
                            mapTemporary{1,9,actID} = old_ActMapData{1,8,actID};
                            mapTemporary{1,10,actID} = old_ActMapData{1,9,actID};
                            mapTemporary{1,11,actID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.CaMeasurement{1,2}{1,3}(:,:, 1:oldDataPage);
                end
                
                
            elseif ID == 2 % Rep
                
                old_Ca_RepVarNum = size( inputData.CaMeasurement{1,2}{2,3}, 2 );
                newRepVarNum = 12;
                
                if old_Ca_RepVarNum ~= newRepVarNum
                    
                    old_RepMapData = inputData.CaMeasurement{1,2}{2,3};
                    repNum = 0;
                    for checkID = 1 : oldDataPage
                        repNum = repNum + ~isempty( old_RepMapData{1,1,checkID} ); % The number of repMap the user has stored
                    end
                    
                    if repNum ~= 0
                        for repID = 1 : repNum % Rep
                            mapTemporary{1,1,repID} = old_RepMapData{1,1,repID};
                            mapTemporary{1,2,repID} = old_RepMapData{1,2,repID};
                            mapTemporary{1,3,repID} = old_RepMapData{1,3,repID};
                            mapTemporary{1,4,repID} = 'Single';
                            mapTemporary{1,5,repID} = old_RepMapData{1,4,repID};
                            mapTemporary{1,6,repID} = old_RepMapData{1,5,repID};
                            mapTemporary{1,7,repID} = old_RepMapData{1,6,repID};
                            mapTemporary{1,8,repID} = old_RepMapData{1,7,repID};
                            mapTemporary{1,9,repID} = old_RepMapData{1,8,repID};
                            mapTemporary{1,10,repID} = old_RepMapData{1,9,repID};
                            mapTemporary{1,11,repID} = old_RepMapData{1,10,repID};
                            mapTemporary{1,12,repID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.CaMeasurement{1,2}{2,3}(:,:, 1:oldDataPage);
                end
                
                
            else
                mapTemporary(:,:, 1:oldDataPage) = inputData.CaMeasurement{1,2}{ID,3}(:,:, 1:oldDataPage);
            end
            
            CaMap_1{ID,3} = mapTemporary;
        end
        
        % Camera 2 Vm ---------
        for ID = 1 : size(VmMap_2,1) % Act, Rep, APD,  RT
            
            mapTemporary = VmMap_2{ID,3}; % ActMapData, RepMapData, APDMapData, RTMapData
            
            if ID == 1 % Act
                
                old_Vm_ActVarNum = size( inputData.VmMeasurement{2,2}{1,3}, 2 ); % The number of parameters inside Act Map
                newActVarNum = 11;
                
                if old_Vm_ActVarNum ~= newActVarNum
                    
                    old_ActMapData = inputData.VmMeasurement{2,2}{1,3};
                    actNum = 0;
                    for checkID = 1 : oldDataPage
                        actNum = actNum + ~isempty( old_ActMapData{1,1,checkID} ); % The number of actMap the user has stored
                    end
                    
                    if actNum ~= 0
                        for actID = 1 : actNum % Act
                            mapTemporary{1,1,actID} = old_ActMapData{1,1,actID};
                            mapTemporary{1,2,actID} = old_ActMapData{1,2,actID};
                            mapTemporary{1,3,actID} = old_ActMapData{1,3,actID};
                            mapTemporary{1,4,actID} = 'Single';
                            mapTemporary{1,5,actID} = old_ActMapData{1,4,actID};
                            mapTemporary{1,6,actID} = old_ActMapData{1,5,actID};
                            mapTemporary{1,7,actID} = old_ActMapData{1,6,actID};
                            mapTemporary{1,8,actID} = old_ActMapData{1,7,actID};
                            mapTemporary{1,9,actID} = old_ActMapData{1,8,actID};
                            mapTemporary{1,10,actID} = old_ActMapData{1,9,actID};
                            mapTemporary{1,11,actID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.VmMeasurement{2,2}{1,3}(:,:, 1:oldDataPage);
                end
                
                
            elseif ID == 2 % Rep
                
                old_Vm_RepVarNum = size( inputData.VmMeasurement{2,2}{2,3}, 2 );
                newRepVarNum = 12;
                
                if old_Vm_RepVarNum ~= newRepVarNum
                    
                    old_RepMapData = inputData.VmMeasurement{2,2}{2,3};
                    repNum = 0;
                    for checkID = 1 : oldDataPage
                        repNum = repNum + ~isempty( old_RepMapData{1,1,checkID} ); % The number of repMap the user has stored
                    end
                    
                    if repNum ~= 0
                        for repID = 1 : repNum % Rep
                            mapTemporary{1,1,repID} = old_RepMapData{1,1,repID};
                            mapTemporary{1,2,repID} = old_RepMapData{1,2,repID};
                            mapTemporary{1,3,repID} = old_RepMapData{1,3,repID};
                            mapTemporary{1,4,repID} = 'Single';
                            mapTemporary{1,5,repID} = old_RepMapData{1,4,repID};
                            mapTemporary{1,6,repID} = old_RepMapData{1,5,repID};
                            mapTemporary{1,7,repID} = old_RepMapData{1,6,repID};
                            mapTemporary{1,8,repID} = old_RepMapData{1,7,repID};
                            mapTemporary{1,9,repID} = old_RepMapData{1,8,repID};
                            mapTemporary{1,10,repID} = old_RepMapData{1,9,repID};
                            mapTemporary{1,11,repID} = old_RepMapData{1,10,repID};
                            mapTemporary{1,12,repID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.VmMeasurement{2,2}{2,3}(:,:, 1:oldDataPage);
                end
                
                
            else
                mapTemporary(:,:, 1:oldDataPage) = inputData.VmMeasurement{2,2}{ID,3}(:,:, 1:oldDataPage);
            end
            
            VmMap_2{ID,3} = mapTemporary;
        end
        
        % Camera 2 Ca
        for ID = 1 : size(CaMap_2,1) % Act, Rep, CaTD,  RT, DT, DTau
            
            mapTemporary = CaMap_2{ID,3}; % ActMapData, RepMapData, CaTDMapData, RTMapData, DTMapData, DTauMapData
            
            if ID == 1 % Act
                
                old_Ca_ActVarNum = size( inputData.CaMeasurement{2,2}{1,3}, 2 ); % The number of parameters inside Act Map
                newActVarNum = 11;
                
                if old_Ca_ActVarNum ~= newActVarNum
                    
                    old_ActMapData = inputData.CaMeasurement{2,2}{1,3};
                    actNum = 0;
                    for checkID = 1 : oldDataPage
                        actNum = actNum + ~isempty( old_ActMapData{1,1,checkID} ); % The number of actMap the user has stored
                    end
                    
                    if actNum ~= 0
                        for actID = 1 : actNum % Act
                            mapTemporary{1,1,actID} = old_ActMapData{1,1,actID};
                            mapTemporary{1,2,actID} = old_ActMapData{1,2,actID};
                            mapTemporary{1,3,actID} = old_ActMapData{1,3,actID};
                            mapTemporary{1,4,actID} = 'Single';
                            mapTemporary{1,5,actID} = old_ActMapData{1,4,actID};
                            mapTemporary{1,6,actID} = old_ActMapData{1,5,actID};
                            mapTemporary{1,7,actID} = old_ActMapData{1,6,actID};
                            mapTemporary{1,8,actID} = old_ActMapData{1,7,actID};
                            mapTemporary{1,9,actID} = old_ActMapData{1,8,actID};
                            mapTemporary{1,10,actID} = old_ActMapData{1,9,actID};
                            mapTemporary{1,11,actID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.CaMeasurement{2,2}{1,3}(:,:, 1:oldDataPage);
                end
                
                
            elseif ID == 2 % Rep
                
                old_Ca_RepVarNum = size( inputData.CaMeasurement{2,2}{2,3}, 2 );
                newRepVarNum = 12;
                
                if old_Ca_RepVarNum ~= newRepVarNum
                    
                    old_RepMapData = inputData.CaMeasurement{2,2}{2,3};
                    repNum = 0;
                    for checkID = 1 : oldDataPage
                        repNum = repNum + ~isempty( old_RepMapData{1,1,checkID} ); % The number of repMap the user has stored
                    end
                    
                    if repNum ~= 0
                        for repID = 1 : repNum % Rep
                            mapTemporary{1,1,repID} = old_RepMapData{1,1,repID};
                            mapTemporary{1,2,repID} = old_RepMapData{1,2,repID};
                            mapTemporary{1,3,repID} = old_RepMapData{1,3,repID};
                            mapTemporary{1,4,repID} = 'Single';
                            mapTemporary{1,5,repID} = old_RepMapData{1,4,repID};
                            mapTemporary{1,6,repID} = old_RepMapData{1,5,repID};
                            mapTemporary{1,7,repID} = old_RepMapData{1,6,repID};
                            mapTemporary{1,8,repID} = old_RepMapData{1,7,repID};
                            mapTemporary{1,9,repID} = old_RepMapData{1,8,repID};
                            mapTemporary{1,10,repID} = old_RepMapData{1,9,repID};
                            mapTemporary{1,11,repID} = old_RepMapData{1,10,repID};
                            mapTemporary{1,12,repID} = [];
                        end
                    end
                    
                else
                    mapTemporary(:,:, 1:oldDataPage) = inputData.CaMeasurement{2,2}{2,3}(:,:, 1:oldDataPage);
                end
                
                
            else
                mapTemporary(:,:, 1:oldDataPage) = inputData.CaMeasurement{2,2}{ID,3}(:,:, 1:oldDataPage);
            end
            
            CaMap_2{ID,3} = mapTemporary;
        end
        
        VmMeasurement = { 'Camera1', VmMap_1; 'Camera2', VmMap_2 }; % Camera 1; Camera 2
        CaMeasurement = { 'Camera1', CaMap_1; 'Camera2', CaMap_2 }; % Camera 1; Camera 2
        
        save(fileName, 'VmMeasurement', 'CaMeasurement',  '-append');
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        if ishandle(f) == 1
            close(f)
        end
    end
    
end









%% ------------------------------------------------------------- %
% Version Check Type V - Update Act and Rep map parameters
sectionID = 5;

% Re-Arrange Variables for Single Camera Files -----------------------
if inputData.camTF == 0 % Single cameras
    
    field = { 'VmMeasurement', 'CaMeasurement' };
    
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    old_Vm_ActVarNum = size( inputData.VmMeasurement{1,2}{1,3}, 2 );
    old_Ca_ActVarNum = size( inputData.CaMeasurement{1,2}{1,3}, 2 );
    newActVarNum = 11;
    
    old_Vm_RepVarNum = size( inputData.VmMeasurement{1,2}{2,3}, 2 );
    old_Ca_RepVarNum = size( inputData.CaMeasurement{1,2}{2,3}, 2 );
    newRepVarNum = 12;
    
    Vm_actTF = (old_Vm_ActVarNum ~= newActVarNum);
    Ca_actTF = (old_Ca_ActVarNum ~= newActVarNum);
    
    Vm_repTF = (old_Vm_RepVarNum ~= newRepVarNum);
    Ca_repTF = (old_Ca_RepVarNum ~= newRepVarNum);
    
    % Need to migrate from old SliceZer to new version
    if ( TF == 1 )  &&  ( Vm_actTF == 1 )  &&  ( Ca_actTF == 1 )  &&  (Vm_repTF == 1)  &&  (Ca_repTF == 1)
        
        oldversionTF = 1; % Old version
        
        msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
        
        
        % Camera 1 Vm
        old_ActMapData = inputData.VmMeasurement{1,2}{1,3};
        old_RepMapData = inputData.VmMeasurement{1,2}{2,3};
        
        actNum = 0;
        for ID = 1 : maxFileNum
            actNum = actNum + ~isempty( old_ActMapData{1,1,ID} ); % The number of actMap the user has stored
        end
        
        repNum = 0;
        for ID = 1 : maxFileNum
            repNum = repNum + ~isempty( old_RepMapData{1,1,ID} ); % The number of repMap the user has stored
        end
        
        if actNum ~= 0
            for actID = 1 : actNum % Act
                
                VmMap{1,3}{1,1,actID} = old_ActMapData{1,1,actID};
                VmMap{1,3}{1,2,actID} = old_ActMapData{1,2,actID};
                VmMap{1,3}{1,3,actID} = old_ActMapData{1,3,actID};
                VmMap{1,3}{1,4,actID} = 'Single';
                VmMap{1,3}{1,5,actID} = old_ActMapData{1,4,actID};
                VmMap{1,3}{1,6,actID} = old_ActMapData{1,5,actID};
                VmMap{1,3}{1,7,actID} = old_ActMapData{1,6,actID};
                VmMap{1,3}{1,8,actID} = old_ActMapData{1,7,actID};
                VmMap{1,3}{1,9,actID} = old_ActMapData{1,8,actID};
                VmMap{1,3}{1,10,actID} = old_ActMapData{1,9,actID};
                VmMap{1,3}{1,11,actID} = [];
            end
        end
        
        if repNum ~= 0
            for repID = 1 : repNum % Rep
                
                VmMap{2,3}{1,1,repID} = old_RepMapData{1,1,repID};
                VmMap{2,3}{1,2,repID} = old_RepMapData{1,2,repID};
                VmMap{2,3}{1,3,repID} = old_RepMapData{1,3,repID};
                VmMap{2,3}{1,4,repID} = 'Single';
                VmMap{2,3}{1,5,repID} = old_RepMapData{1,4,repID};
                VmMap{2,3}{1,6,repID} = old_RepMapData{1,5,repID};
                VmMap{2,3}{1,7,repID} = old_RepMapData{1,6,repID};
                VmMap{2,3}{1,8,repID} = old_RepMapData{1,7,repID};
                VmMap{2,3}{1,9,repID} = old_RepMapData{1,8,repID};
                VmMap{2,3}{1,10,repID} = old_RepMapData{1,9,repID};
                VmMap{2,3}{1,11,repID} = old_RepMapData{1,10,repID};
                VmMap{2,3}{1,12,repID} = [];
            end
        end
        
        for ID = 3 : size(VmMap,1) % APD,  RT
            
            VmMap{ID,3} = inputData.VmMeasurement{1,2}{ID,3};
        end
        
        
        
        % Camera 1 Ca
        old_ActMapData = inputData.CaMeasurement{1,2}{1,3};
        old_RepMapData = inputData.CaMeasurement{1,2}{2,3};
        
        actNum = 0;
        for ID = 1 : maxFileNum
            actNum = actNum + ~isempty( old_ActMapData{1,1,ID} ); % The number of actMap the user has stored
        end
        
        repNum = 0;
        for ID = 1 : maxFileNum
            repNum = repNum + ~isempty( old_RepMapData{1,1,ID} ); % The number of repMap the user has stored
        end
        
        if actNum ~= 0
            for actID = 1 : actNum % Act
                
                CaMap{1,3}{1,1,actID} = old_ActMapData{1,1,actID};
                CaMap{1,3}{1,2,actID} = old_ActMapData{1,2,actID};
                CaMap{1,3}{1,3,actID} = old_ActMapData{1,3,actID};
                CaMap{1,3}{1,4,actID} = 'Single';
                CaMap{1,3}{1,5,actID} = old_ActMapData{1,4,actID};
                CaMap{1,3}{1,6,actID} = old_ActMapData{1,5,actID};
                CaMap{1,3}{1,7,actID} = old_ActMapData{1,6,actID};
                CaMap{1,3}{1,8,actID} = old_ActMapData{1,7,actID};
                CaMap{1,3}{1,9,actID} = old_ActMapData{1,8,actID};
                CaMap{1,3}{1,10,actID} = old_ActMapData{1,9,actID};
                CaMap{1,3}{1,11,actID} = [];
            end
        end
        
        if repNum ~= 0
            for repID = 1 : repNum % Rep
                
                CaMap{2,3}{1,1,repID} = old_RepMapData{1,1,repID};
                CaMap{2,3}{1,2,repID} = old_RepMapData{1,2,repID};
                CaMap{2,3}{1,3,repID} = old_RepMapData{1,3,repID};
                CaMap{2,3}{1,4,repID} = 'Single';
                CaMap{2,3}{1,5,repID} = old_RepMapData{1,4,repID};
                CaMap{2,3}{1,6,repID} = old_RepMapData{1,5,repID};
                CaMap{2,3}{1,7,repID} = old_RepMapData{1,6,repID};
                CaMap{2,3}{1,8,repID} = old_RepMapData{1,7,repID};
                CaMap{2,3}{1,9,repID} = old_RepMapData{1,8,repID};
                CaMap{2,3}{1,10,repID} = old_RepMapData{1,9,repID};
                CaMap{2,3}{1,11,repID} = old_RepMapData{1,10,repID};
                CaMap{2,3}{1,12,repID} = [];
            end
        end
        
        for ID = 3 : size(CaMap,1) % CaTD,  RT, DT, DTau
            
            CaMap{ID,3} = inputData.CaMeasurement{1,2}{ID,3};
        end
        
        
        
        VmMeasurement = { 'Camera1', VmMap }; % Camera 1
        CaMeasurement = { 'Camera1', CaMap }; % Camera 1
        
        save(fileName, 'VmMeasurement', 'CaMeasurement',  '-append');
        
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        if ishandle(f) == 1
            close(f)
        end
    end
    
    
    
else % Re-Arrange Variables for Dual Camera Files -----------------------
    
    field = { 'VmMeasurement', 'CaMeasurement' };
    
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    old_Vm_ActVarNum_Cam1 = size( inputData.VmMeasurement{1,2}{1,3}, 2 );
    old_Ca_ActVarNum_Cam1 = size( inputData.CaMeasurement{1,2}{1,3}, 2 );
    old_Vm_ActVarNum_Cam2 = size( inputData.VmMeasurement{2,2}{1,3}, 2 );
    old_Ca_ActVarNum_Cam2 = size( inputData.CaMeasurement{2,2}{1,3}, 2 );
    newActVarNum = 11;
    
    old_Vm_RepVarNum_Cam1 = size( inputData.VmMeasurement{1,2}{2,3}, 2 );
    old_Ca_RepVarNum_Cam1 = size( inputData.CaMeasurement{1,2}{2,3}, 2 );
    old_Vm_RepVarNum_Cam2 = size( inputData.VmMeasurement{2,2}{2,3}, 2 );
    old_Ca_RepVarNum_Cam2 = size( inputData.CaMeasurement{2,2}{2,3}, 2 );
    newRepVarNum = 12;
    
    Vm_actTF_Cam1 = (old_Vm_ActVarNum_Cam1 ~= newActVarNum);
    Ca_actTF_Cam1 = (old_Ca_ActVarNum_Cam1 ~= newActVarNum);
    Vm_actTF_Cam2 = (old_Vm_ActVarNum_Cam2 ~= newActVarNum);
    Ca_actTF_Cam2 = (old_Ca_ActVarNum_Cam2 ~= newActVarNum);
    
    Vm_repTF_Cam1 = (old_Vm_RepVarNum_Cam1 ~= newRepVarNum);
    Ca_repTF_Cam1 = (old_Ca_RepVarNum_Cam1 ~= newRepVarNum);
    Vm_repTF_Cam2 = (old_Vm_RepVarNum_Cam2 ~= newRepVarNum);
    Ca_repTF_Cam2 = (old_Ca_RepVarNum_Cam2 ~= newRepVarNum);
    
    % Need to migrate from old SliceZer to new version
    if ( TF == 1 )  &&  ( Vm_actTF_Cam1 == 1 )  &&  ( Ca_actTF_Cam1 == 1 )  &&  (Vm_repTF_Cam1 == 1)  &&  (Ca_repTF_Cam1 == 1)  &&  ( Vm_actTF_Cam2 == 1 )  &&  ( Ca_actTF_Cam2 == 1 )  &&  (Vm_repTF_Cam2 == 1)  &&  (Ca_repTF_Cam2 == 1)
        
        oldversionTF = 1; % Old version
        
        msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
        
        VmMap_1 = VmMap; % Camera 1
        VmMap_2 = VmMap; % Camera 2
        
        CaMap_1 = CaMap; % Camera 1
        CaMap_2 = CaMap; % Camera 2
        
        
        % Camera 1 Vm
        old_ActMapData = inputData.VmMeasurement{1,2}{1,3};
        old_RepMapData = inputData.VmMeasurement{1,2}{2,3};
        
        actNum = 0;
        for ID = 1 : maxFileNum
            actNum = actNum + ~isempty( old_ActMapData{1,1,ID} ); % The number of actMap the user has stored
        end
        
        repNum = 0;
        for ID = 1 : maxFileNum
            repNum = repNum+ ~isempty( old_RepMapData{1,1,ID} ); % The number of repMap the user has stored
        end
        
        if actNum ~= 0
            for actID = 1 : actNum % Act
                
                VmMap_1{1,3}{1,1,actID} = old_ActMapData{1,1,actID};
                VmMap_1{1,3}{1,2,actID} = old_ActMapData{1,2,actID};
                VmMap_1{1,3}{1,3,actID} = old_ActMapData{1,3,actID};
                VmMap_1{1,3}{1,4,actID} = 'Single';
                VmMap_1{1,3}{1,5,actID} = old_ActMapData{1,4,actID};
                VmMap_1{1,3}{1,6,actID} = old_ActMapData{1,5,actID};
                VmMap_1{1,3}{1,7,actID} = old_ActMapData{1,6,actID};
                VmMap_1{1,3}{1,8,actID} = old_ActMapData{1,7,actID};
                VmMap_1{1,3}{1,9,actID} = old_ActMapData{1,8,actID};
                VmMap_1{1,3}{1,10,actID} = old_ActMapData{1,9,actID};
                VmMap_1{1,3}{1,11,actID} = [];
            end
        end
        
        if repNum ~= 0
            for repID = 1 : repNum % Rep
                
                VmMap_1{2,3}{1,1,repID} = old_RepMapData{1,1,repID};
                VmMap_1{2,3}{1,2,repID} = old_RepMapData{1,2,repID};
                VmMap_1{2,3}{1,3,repID} = old_RepMapData{1,3,repID};
                VmMap_1{2,3}{1,4,repID} = 'Single';
                VmMap_1{2,3}{1,5,repID} = old_RepMapData{1,4,repID};
                VmMap_1{2,3}{1,6,repID} = old_RepMapData{1,5,repID};
                VmMap_1{2,3}{1,7,repID} = old_RepMapData{1,6,repID};
                VmMap_1{2,3}{1,8,repID} = old_RepMapData{1,7,repID};
                VmMap_1{2,3}{1,9,repID} = old_RepMapData{1,8,repID};
                VmMap_1{2,3}{1,10,repID} = old_RepMapData{1,9,repID};
                VmMap_1{2,3}{1,11,repID} = old_RepMapData{1,10,repID};
                VmMap_1{2,3}{1,12,repID} = [];
            end
        end
        
        for ID = 3 : size(VmMap_1,1) % APD,  RT
            
            VmMap_1{ID,3} = inputData.VmMeasurement{1,2}{ID,3};
        end
        
        
        % Camera 1 Ca
        old_ActMapData = inputData.CaMeasurement{1,2}{1,3};
        old_RepMapData = inputData.CaMeasurement{1,2}{2,3};
        
        actNum = 0;
        for ID = 1 : maxFileNum
            actNum = actNum + ~isempty( old_ActMapData{1,1,ID} ); % The number of actMap the user has stored
        end
        
        repNum = 0;
        for ID = 1 : maxFileNum
            repNum = repNum + ~isempty( old_RepMapData{1,1,ID} ); % The number of repMap the user has stored
        end
        
        if actNum ~= 0
            for actID = 1 : actNum % Act
                
                CaMap_1{1,3}{1,1,actID} = old_ActMapData{1,1,actID};
                CaMap_1{1,3}{1,2,actID} = old_ActMapData{1,2,actID};
                CaMap_1{1,3}{1,3,actID} = old_ActMapData{1,3,actID};
                CaMap_1{1,3}{1,4,actID} = 'Single';
                CaMap_1{1,3}{1,5,actID} = old_ActMapData{1,4,actID};
                CaMap_1{1,3}{1,6,actID} = old_ActMapData{1,5,actID};
                CaMap_1{1,3}{1,7,actID} = old_ActMapData{1,6,actID};
                CaMap_1{1,3}{1,8,actID} = old_ActMapData{1,7,actID};
                CaMap_1{1,3}{1,9,actID} = old_ActMapData{1,8,actID};
                CaMap_1{1,3}{1,10,actID} = old_ActMapData{1,9,actID};
                CaMap_1{1,3}{1,11,actID} = [];
            end
        end
        
        if repNum ~= 0
            for repID = 1 : repNum % Rep
                
                CaMap_1{2,3}{1,1,repID} = old_RepMapData{1,1,repID};
                CaMap_1{2,3}{1,2,repID} = old_RepMapData{1,2,repID};
                CaMap_1{2,3}{1,3,repID} = old_RepMapData{1,3,repID};
                CaMap_1{2,3}{1,4,repID} = 'Single';
                CaMap_1{2,3}{1,5,repID} = old_RepMapData{1,4,repID};
                CaMap_1{2,3}{1,6,repID} = old_RepMapData{1,5,repID};
                CaMap_1{2,3}{1,7,repID} = old_RepMapData{1,6,repID};
                CaMap_1{2,3}{1,8,repID} = old_RepMapData{1,7,repID};
                CaMap_1{2,3}{1,9,repID} = old_RepMapData{1,8,repID};
                CaMap_1{2,3}{1,10,repID} = old_RepMapData{1,9,repID};
                CaMap_1{2,3}{1,11,repID} = old_RepMapData{1,10,repID};
                CaMap_1{2,3}{1,12,repID} = [];
            end
        end
        
        for ID = 3 : size(CaMap_1,1) % CaTD,  RT, DT, DTau
            
            CaMap_1{ID,3} = inputData.CaMeasurement{1,2}{ID,3};
        end
        
        
        % Camera 2 Vm
        old_ActMapData = inputData.VmMeasurement{2,2}{1,3};
        old_RepMapData = inputData.VmMeasurement{2,2}{2,3};
        
        actNum = 0;
        for ID = 1 : maxFileNum
            actNum = actNum + ~isempty( old_ActMapData{1,1,ID} ); % The number of actMap the user has stored
        end
        
        repNum = 0;
        for ID = 1 : maxFileNum
            repNum = repNum + ~isempty( old_RepMapData{1,1,ID} ); % The number of repMap the user has stored
        end
        
        if actNum ~= 0
            for actID = 1 : actNum % Act
                
                VmMap_2{1,3}{1,1,actID} = old_ActMapData{1,1,actID};
                VmMap_2{1,3}{1,2,actID} = old_ActMapData{1,2,actID};
                VmMap_2{1,3}{1,3,actID} = old_ActMapData{1,3,actID};
                VmMap_2{1,3}{1,4,actID} = 'Single';
                VmMap_2{1,3}{1,5,actID} = old_ActMapData{1,4,actID};
                VmMap_2{1,3}{1,6,actID} = old_ActMapData{1,5,actID};
                VmMap_2{1,3}{1,7,actID} = old_ActMapData{1,6,actID};
                VmMap_2{1,3}{1,8,actID} = old_ActMapData{1,7,actID};
                VmMap_2{1,3}{1,9,actID} = old_ActMapData{1,8,actID};
                VmMap_2{1,3}{1,10,actID} = old_ActMapData{1,9,actID};
                VmMap_2{1,3}{1,11,actID} = [];
            end
        end
        
        if repNum ~= 0
            for repID = 1 : repNum % Rep
                
                VmMap_2{2,3}{1,1,repID} = old_RepMapData{1,1,repID};
                VmMap_2{2,3}{1,2,repID} = old_RepMapData{1,2,repID};
                VmMap_2{2,3}{1,3,repID} = old_RepMapData{1,3,repID};
                VmMap_2{2,3}{1,4,repID} = 'Single';
                VmMap_2{2,3}{1,5,repID} = old_RepMapData{1,4,repID};
                VmMap_2{2,3}{1,6,repID} = old_RepMapData{1,5,repID};
                VmMap_2{2,3}{1,7,repID} = old_RepMapData{1,6,repID};
                VmMap_2{2,3}{1,8,repID} = old_RepMapData{1,7,repID};
                VmMap_2{2,3}{1,9,repID} = old_RepMapData{1,8,repID};
                VmMap_2{2,3}{1,10,repID} = old_RepMapData{1,9,repID};
                VmMap_2{2,3}{1,11,repID} = old_RepMapData{1,10,repID};
                VmMap_2{2,3}{1,12,repID} = [];
            end
        end
        
        for ID = 3 : size(VmMap_2,1) % APD,  RT
            
            VmMap_2{ID,3} = inputData.VmMeasurement{2,2}{ID,3};
        end
        
        
        % Camera 2 Ca
        old_ActMapData = inputData.CaMeasurement{2,2}{1,3};
        old_RepMapData = inputData.CaMeasurement{2,2}{2,3};
        
        actNum = 0;
        for ID = 1 : maxFileNum
            actNum = actNum + ~isempty( old_ActMapData{1,1,ID} ); % The number of actMap the user has stored
        end
        
        repNum = 0;
        for ID = 1 : maxFileNum
            repNum = repNum + ~isempty( old_RepMapData{1,1,ID} ); % The number of repMap the user has stored
        end
        
        if actNum ~= 0
            for actID = 1 : actNum % Act
                
                CaMap_2{1,3}{1,1,actID} = old_ActMapData{1,1,actID};
                CaMap_2{1,3}{1,2,actID} = old_ActMapData{1,2,actID};
                CaMap_2{1,3}{1,3,actID} = old_ActMapData{1,3,actID};
                CaMap_2{1,3}{1,4,actID} = 'Single';
                CaMap_2{1,3}{1,5,actID} = old_ActMapData{1,4,actID};
                CaMap_2{1,3}{1,6,actID} = old_ActMapData{1,5,actID};
                CaMap_2{1,3}{1,7,actID} = old_ActMapData{1,6,actID};
                CaMap_2{1,3}{1,8,actID} = old_ActMapData{1,7,actID};
                CaMap_2{1,3}{1,9,actID} = old_ActMapData{1,8,actID};
                CaMap_2{1,3}{1,10,actID} = old_ActMapData{1,9,actID};
                CaMap_2{1,3}{1,11,actID} = [];
            end
        end
        
        if repNum ~= 0
            for repID = 1 : repNum % Rep
                
                CaMap_2{2,3}{1,1,repID} = old_RepMapData{1,1,repID};
                CaMap_2{2,3}{1,2,repID} = old_RepMapData{1,2,repID};
                CaMap_2{2,3}{1,3,repID} = old_RepMapData{1,3,repID};
                CaMap_2{2,3}{1,4,repID} = 'Single';
                CaMap_2{2,3}{1,5,repID} = old_RepMapData{1,4,repID};
                CaMap_2{2,3}{1,6,repID} = old_RepMapData{1,5,repID};
                CaMap_2{2,3}{1,7,repID} = old_RepMapData{1,6,repID};
                CaMap_2{2,3}{1,8,repID} = old_RepMapData{1,7,repID};
                CaMap_2{2,3}{1,9,repID} = old_RepMapData{1,8,repID};
                CaMap_2{2,3}{1,10,repID} = old_RepMapData{1,9,repID};
                CaMap_2{2,3}{1,11,repID} = old_RepMapData{1,10,repID};
                CaMap_2{2,3}{1,12,repID} = [];
            end
        end
        
        for ID = 3 : size(CaMap_1,1) % CaTD,  RT, DT, DTau
            
            CaMap_2{ID,3} = inputData.CaMeasurement{2,2}{ID,3};
        end
        
        
        VmMeasurement = { 'Camera1', VmMap_1; 'Camera2', VmMap_2 }; % Camera 1; Camera 2
        CaMeasurement = { 'Camera1', CaMap_1; 'Camera2', CaMap_2 }; % Camera 1; Camera 2
        
        save(fileName, 'VmMeasurement', 'CaMeasurement',  '-append');
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        if ishandle(f) == 1
            close(f)
        end
    end
    
end








%% ------------------------------------------------------------- %
% Version Check Type VI
sectionID = 6;

field = { 'systemSetupComment' };

TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)

if ( TF == 0 ) % Does not exist
    
    oldversionTF = 1; % Old version
    
    msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
    f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
    
    systemSetupComment = cell(5,2);
    systemSetupComment{1,1} = 'Camera Mode (or Number)';
    systemSetupComment{2,1} = 'View Mode';
    systemSetupComment{3,1} = 'Signal Type';
    systemSetupComment{4,1} = 'Camera 1 Signal Type';
    systemSetupComment{5,1} = 'Camera 2 Signal Type';
    systemSetupComment{1,2} = 'N/A';
    systemSetupComment{2,2} = 'N/A';
    systemSetupComment{3,2} = 'N/A';
    systemSetupComment{4,2} = 'N/A';
    systemSetupComment{5,2} = 'N/A';
    
    if inputData.camTF == 0 % Single cameras
        systemSetupComment{1,2} = 'Single';
    else
        systemSetupComment{1,2} = 'Dual';
    end
    
    save(fileName, 'systemSetupComment',  '-append');
    
    % After saving, refresh inputData
    inputData = load(fileName);
    
    if ishandle(f) == 1
        close(f)
    end
end






%% ------------------------------------------------------------- %
% Version Check Type VII - Add CV Map for VmMeasurement
sectionID = 7;

% Re-Arrange Variables for Single Camera Files -----------------------
if inputData.camTF == 0 % Single cameras
    
    field = { 'VmMeasurement' };
    
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    CVMap_Exist = 0;
    old_VmMap = inputData.VmMeasurement{1,2};
    varNum = size(old_VmMap, 1);
    for ID = 1 : varNum
        CVMap_Exist = CVMap_Exist + contains( old_VmMap{ID,1}, 'CV' );
    end
    
    
    % Need to migrate from old SliceZer to new version
    if ( TF == 1 )  &&  ( CVMap_Exist == 0)  &&  ( varNum == 4 )
        
        oldversionTF = 1; % Old version
        
        msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
        
        new_VmMap = old_VmMap;
        
        CVMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
            'Act Matrix', 'CVVectorMatrix', 'CVVectorAngleMatrix', 'CVVectorSpeedMatrix', ...
            'CVDirectingLineStartXY', 'CVDirectingLineEndXY', 'CVDirectingLineSubVectorMatrix', ...
            'LineAngleDegree', 'VectorMembers', 'DistancewithinPixel', 'AnglewithinDegree', ...
            'Pseudo Data Time', 'Data Section', 'Locs Act', 'Ensemble Peaks Number' };
        CVMapData = cell(1,19, maxFileNum);
        
        new_VmMap{varNum + 1 ,1} = 'CV';
        new_VmMap{varNum + 1 ,2} = CVMapDataTitle;
        new_VmMap{varNum + 1 ,3} = CVMapData;
        clear CVMapDataTitle CVMapData
        
        
        VmMeasurement = { 'Camera1', new_VmMap }; % Camera 1
        
        save(fileName, 'VmMeasurement', '-append');
        
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        if ishandle(f) == 1
            close(f)
        end
    end
    
    
    
    
else % Re-Arrange Variables for Dual Camera Files -----------------------
    
    field = { 'VmMeasurement' };
    
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    CVMap_Exist_Cam1 = 0;
    old_VmMap_Cam1 = inputData.VmMeasurement{1,2};
    varNum_Cam1 = size(old_VmMap_Cam1, 1);
    for ID = 1 : varNum_Cam1
        CVMap_Exist_Cam1 = CVMap_Exist_Cam1 + contains( old_VmMap_Cam1{ID,1}, 'CV' );
    end
    
    CVMap_Exist_Cam2 = 0;
    old_VmMap_Cam2 = inputData.VmMeasurement{2,2};
    varNum_Cam2 = size(old_VmMap_Cam2, 1);
    for ID = 1 : varNum_Cam2
        CVMap_Exist_Cam2 = CVMap_Exist_Cam2 + contains( old_VmMap_Cam2{ID,1}, 'CV' );
    end
    
    
    % Need to migrate from old SliceZer to new version
    if ( TF == 1 )  &&  ( CVMap_Exist_Cam1 == 0)  &&  ( varNum_Cam1 == 4 )  &&  ( CVMap_Exist_Cam2 == 0)  &&  ( varNum_Cam2 == 4 )
        
        oldversionTF = 1; % Old version
        
        msg = [ 'File migrating from the old version SliceZer to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
        
        new_VmMap_Cam1 = old_VmMap_Cam1;
        new_VmMap_Cam2 = old_VmMap_Cam2;
        
        CVMapDataTitle = { 'Win Start Index', 'Win End Index', 'Area Mode', 'AP Mode', ...
            'Act Matrix', 'CVVectorMatrix', 'CVVectorAngleMatrix', 'CVVectorSpeedMatrix', ...
            'CVDirectingLineStartXY', 'CVDirectingLineEndXY', 'CVDirectingLineSubVectorMatrix', ...
            'LineAngleDegree', 'VectorMembers', 'DistancewithinPixel', 'AnglewithinDegree', ...
            'Pseudo Data Time', 'Data Section', 'Locs Act', 'Ensemble Peaks Number' };
        CVMapData = cell(1,19, maxFileNum);
        
        new_VmMap_Cam1{varNum_Cam1 + 1 ,1} = 'CV';
        new_VmMap_Cam1{varNum_Cam1 + 1 ,2} = CVMapDataTitle;
        new_VmMap_Cam1{varNum_Cam1 + 1 ,3} = CVMapData;
        
        new_VmMap_Cam2{varNum_Cam2 + 1 ,1} = 'CV';
        new_VmMap_Cam2{varNum_Cam2 + 1 ,2} = CVMapDataTitle;
        new_VmMap_Cam2{varNum_Cam2 + 1 ,3} = CVMapData;
        clear CVMapDataTitle CVMapData
        
        
        VmMeasurement = { 'Camera1', new_VmMap_Cam1; 'Camera2', new_VmMap_Cam2 }; % Camera 1; Camera 2
        
        save(fileName, 'VmMeasurement', '-append');
        
        
        % After saving, refresh inputData
        inputData = load(fileName);
        
        if ishandle(f) == 1
            close(f)
        end
    end
end






end