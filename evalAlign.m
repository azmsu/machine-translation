%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = 'A2_SMT/data/Hansard/Training';
testDir      = 'A2_SMT/data/Hansard/Testing';
fn_LME       = 'lm_e.mat';
fn_LMF       = 'lm_f.mat';
lm_type      = 'smooth';
delta        = 0.5;
vocabSize    = 27041; 
% numSentences = TODO;

load('lm_english.mat');
load('am_30.mat');

% Train your language models. This is task 2 which makes use of task 1
% LME = lm_train(trainDir, 'e', fn_LME);
% LMF = lm_train(trainDir, 'f', fn_LMF);

% Train your alignment model of French, given English 
% AMFE = align_ibm1(trainDir, numSentences);
% ... TODO: more 

fre_file = textread('A2_SMT/data/Hansard/Testing/Task5.f', '%s', 'delimiter', '\n');
ref1_file = textread('A2_SMT/data/Hansard/Testing/Task5.google.e', '%s', 'delimiter', '\n');
ref2_file = textread('A2_SMT/data/Hansard/Testing/Task5.e', '%s', 'delimiter', '\n');

% loop through sentences
for i=1:length(fre_file)
    ref1 = preprocess(ref1_file{i}, 'e');
    ref2 = preprocess(ref2_file{i}, 'e');
    fre = preprocess(fre_file{i}, 'f');
    
    % decode the test sentence 'fre'
    cand = decode2(fre, LM, AM, 'smooth', delta, vocabSize)
    
    ref1_words = strsplit(' ', ref1);
    ref1_words = ref1_words(:, 2:length(ref1_words)-1);
    ref2_words = strsplit(' ', ref2);
    ref2_words = ref2_words(:, 2:length(ref2_words)-1);
    cand_words = strsplit(' ', cand);
    cand_words = cand_words(:, 2:length(cand_words)-1);
    
    [cand_uni, cand_bi, cand_tri] = get_ngrams(cand_words);
    [ref1_uni, ref1_bi, ref1_tri] = get_ngrams(ref1_words);
    [ref2_uni, ref2_bi, ref2_tri] = get_ngrams(ref2_words);
    
    cap = 2;
    
    % unigram precision   
    p1 = 0;
    cand_fields = fields(cand_uni);
    for j=1:length(cand_fields)
        if isfield(ref1_uni, cand_fields{j})
            p1 = p1 + min(cap, cand_uni.(cand_fields{j}));
            cand_uni.(cand_fields{j}) = Inf;
        end
        if isfield(ref2_uni, cand_fields{j})
            if cand_uni.(cand_fields{j}) ~= Inf
                p1 = p1 + min(cap, cand_uni.(cand_fields{j}));
            end
        end
    end
    
    p1 = p1/length(cand_fields);
    
    % bigram precision
    p2 = 0;
    f_fields = fields(cand_bi);
    for j=1:length(f_fields)
        if isfield(ref1_bi, f_fields{j})
            s_fields = fields(cand_bi.(f_fields{j}));
            for k=1:length(s_fields)
                if isfield(ref1_bi.(f_fields{j}), s_fields{k})
                    p2 = p2 + min(cap, cand_bi.(f_fields{j}).(s_fields{k}));
                    cand_bi.(f_fields{j}).(s_fields{k}) = Inf;
                end
            end
        end
        
        if isfield(ref2_bi, f_fields{j})
            s_fields = fields(cand_bi.(f_fields{j}));
            for k=1:length(s_fields)
                if isfield(ref2_bi.(f_fields{j}), s_fields{k})
                    if cand_bi.(f_fields{j}).(s_fields{k}) ~= Inf;
                        p2 = p2 + min(cap, cand_bi.(f_fields{j}).(s_fields{k}));
                    end
                end
            end
        end
    end
    
    p2 = p2/length(f_fields);
    
    % trigram precision
    p3 = 0;
    f_fields = fields(cand_tri);
    for j=1:length(f_fields)
        if isfield(ref1_tri, f_fields{j})
            s_fields = fields(cand_tri.(f_fields{j}));
            for k=1:length(s_fields)
                if isfield(ref1_tri.(f_fields{j}), s_fields{k})
                    t_fields = fields(cand_tri.(f_fields{j}).(s_fields{k}));
                    for l=1:length(t_fields)
                        if isfield(ref1_tri.(f_fields{j}).(s_fields{k}), t_fields{l})
                            p3 = p3 + min(cap, cand_tri.(f_fields{j}).(s_fields{k}).(t_fields{l}));
                            cand_tri.(f_fields{j}).(s_fields{k}).(t_fields{l}) = Inf;
                        end
                    end
                end
            end
        end
        
        if isfield(ref2_tri, f_fields{j})
            s_fields = fields(cand_tri.(f_fields{j}));
            for k=1:length(s_fields)
                if isfield(ref2_tri.(f_fields{j}), s_fields{k})
                    t_fields = fields(cand_tri.(f_fields{j}).(s_fields{k}));
                    for l=1:length(t_fields)
                        if isfield(ref2_tri.(f_fields{j}).(s_fields{k}), t_fields{l})
                            if cand_tri.(f_fields{j}).(s_fields{k}).(t_fields{l}) ~= Inf
                                p3 = p3 + min(cap, cand_tri.(f_fields{j}).(s_fields{k}).(t_fields{l}));
                            end
                        end
                    end
                end
            end
        end
    end
    
    p3 = p3/length(f_fields);
    
    % brevity
    cand_length = length(cand_words);
    ref1_length = length(ref1_words);
    ref2_length = length(ref2_words);
    
    if cand_length - ref1_length > cand_length - ref2_length
        bp = ref2_length/cand_length;
    else
        bp = ref1_length/cand_length;
    end
    
    if bp < 1
        bp = 1;
    else
        bp = exp(1-bp);
    end
    
    bleu1 = bp * p1
    bleu2 = bp * (p1 * p2)^(1/2)
    bleu3 = bp * (p1 * p2 * p3)^(1/3)
end

% [status, result] = unix('')


