function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
%  Zi Mo Su
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
    global CSC401_A2_DEFNS

    % Read in the training data
    [eng, fre] = read_hansard(trainDir, numSentences);

    % Initialize AM uniformly 
    AM = initialize(eng, fre);

    tcount = struct();
    total = struct();
    for i=1:length(fre)
        fre_sent = fre{i}(:, 2:length(fre{i})-1);
        eng_sent = eng{i}(:, 2:length(eng{i})-1);
        for j=1:length(eng_sent)
            total.(eng_sent{j}) = 0;
            for k=1:length(fre_sent)
                tcount.(eng_sent{j}).(fre_sent{k}) = 0;   
            end
        end
    end
    
    % Iterate between E and M steps
    for iter=1:maxIter,
    AM = em_step(AM, eng, fre, tcount, total);
    end

    % Save the alignment model
    save( fn_AM, 'AM', '-mat'); 

end

  
% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------
function [eng, fre] = read_hansard(dataDir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
    eng = {};
    fre = {};
    
    eng_files = dir([dataDir, filesep, '*e']);
    
    lines_eng = [];
    lines_fre = [];
    lines = 0;
    i = 1;
    while length(lines_eng) < numSentences
        lines_eng = [lines_eng; textread([dataDir, filesep, eng_files(i).name], '%s', 'delimiter', '\n')];
        fre_fn = [eng_files(i).name(:, 1:length(eng_files(i).name)-1) 'f'];
        lines_fre = [lines_fre; textread([dataDir, filesep, fre_fn], '%s', 'delimiter', '\n')];
        i = i + 1;
    end
    
    for i=1:numSentences
        eng{i} = strsplit(' ', preprocess(lines_eng{i}, 'e'));
        fre{i} = strsplit(' ', preprocess(lines_fre{i}, 'f'));
    end
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)
    count = struct();
    
    for i=1:length(eng)
        eng_sent = eng{i}(:, 2:length(eng{i})-1);
        fre_sent = fre{i}(:, 2:length(fre{i})-1);
        for j=1:length(eng_sent)
            if isfield(AM, eng_sent{j}) == 0
                AM.(eng_sent{j}) = struct();
                count.(eng_sent{j}) = 0;
            end
            count.(eng_sent{j}) = count.(eng_sent{j}) + length(fre_sent);
            for k=1:length(fre_sent)
                if isfield(AM.(eng_sent{j}), fre_sent{k})
                    AM.(eng_sent{j}).(fre_sent{k}) = AM.(eng_sent{j}).(fre_sent{k}) + 1;
                else
                    AM.(eng_sent{j}).(fre_sent{k}) = 1;
                end
            end
        end
    end
    
    eng_words = fieldnames(AM);
    for i=1:length(eng_words)
        if strcmp(eng_words{i}, 'SENTSTART') || strcmp(eng_words{i}, 'SENTEND')
            continue
        end
        fre_words = fieldnames(AM.(eng_words{i}));
        for j=1:length(fre_words)
            if strcmp(fre_words{j}, 'SENTSTART') || strcmp(fre_words{j}, 'SENTSTART')
                continue
            end
            AM.(eng_words{i}).(fre_words{j}) = (AM.(eng_words{i}).(fre_words{j}))/(count.(eng_words{i}));
        end
    end
    
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;
    
end


function t = em_step(t, eng, fre, tc, tot)
% 
% One step in the EM algorithm.
%   
    % initialize tcount and total structures with all zeros
    tcount = struct(tc);
    total = struct(tot);

    % estimation
    for i=1:length(fre)
        fre_sent = fre{i}(:, 2:length(fre{i})-1);
        eng_sent = eng{i}(:, 2:length(eng{i})-1);
        
        unique_fre = unique(fre_sent, 'stable');
        unique_fre_count = cellfun(@(x) sum(ismember(fre_sent, x)), unique_fre, 'un', 0);
        unique_eng = unique(eng_sent, 'stable');
        unique_eng_count = cellfun(@(x) sum(ismember(eng_sent, x)), unique_eng, 'un', 0);
        
        for j=1:length(unique_fre)
            denom_c = 0;
            for k=1:length(unique_eng)
                denom_c = denom_c + t.(unique_eng{k}).(unique_fre{j}) * unique_fre_count{j};
            end
            for k=1:length(unique_eng)
                e = unique_eng{k};
                f = unique_fre{j};
                ecount = unique_eng_count{k};
                fcount = unique_fre_count{j};
                tcount.(e).(f) = tcount.(e).(f) + t.(e).(f) * fcount * ecount / denom_c;
                total.(e) = total.(e) + t.(e).(f) * fcount * ecount / denom_c;
            end
        end
    end
    
    % maximization
    eng_words = fields(total);
    for i=1:length(eng_words)
        e = eng_words{i};
        fre_words = fields(tcount.(e));
        for j=1:length(fre_words)
            f = fre_words{j};
            t.(e).(f) = tcount.(e).(f) / total.(e);
        end
    end
    
end

