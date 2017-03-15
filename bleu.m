function [bleu1, bleu2, bleu3] = bleu(cand, ref1, ref2, cap)
%  
%  bleu
%  Zi Mo Su
%
%  This function computes the BLEU scores for a candidate translation given 
%  two references
%
%  INPUTS:
%
%       cand    : (string) preprocessed candidate english sentence
%       ref1    : (string) preprocessed reference english sentence 1
%       ref1    : (string) preprocessed reference english sentence 2
%       cap     : (integer) maximum number of counts a word in cand contributes
%                           towards the precision
%
%  OUTPUTS:
%
%       bleu1   : (float) bleu score for n = 1
%       bleu2   : (float) bleu score for n = 2
%       bleu3   : (float) bleu score for n = 3
%

    ref1_words = strsplit(' ', ref1);
    ref1_words = ref1_words(:, 2:length(ref1_words)-1);
    ref2_words = strsplit(' ', ref2);
    ref2_words = ref2_words(:, 2:length(ref2_words)-1);
    cand_words = strsplit(' ', cand);
    cand_words = cand_words(:, 2:length(cand_words)-1);

    [cand_uni, cand_bi, cand_tri] = get_ngrams(cand_words);
    [ref1_uni, ref1_bi, ref1_tri] = get_ngrams(ref1_words);
    [ref2_uni, ref2_bi, ref2_tri] = get_ngrams(ref2_words);
    
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
    
    if abs(cand_length - ref1_length) > abs(cand_length - ref2_length)
        bp = ref2_length/cand_length;
    else
        bp = ref1_length/cand_length;
    end
    
    if bp < 1
        bp = 1;
    else
        bp = exp(1-bp);
    end
    
    bleu1 = bp * p1;
    bleu2 = bp * (p1 * p2)^(1/2);
    bleu3 = bp * (p1 * p2 * p3)^(1/3);
end


% --------------------------------------------------------------------------------
% 
%  Support function
%
% --------------------------------------------------------------------------------
function [unigrams, bigrams, trigrams] = get_ngrams(words)
%
% Create unigrams, bigrams and trigrams structures for sentence given by words.
%  
    unigrams = struct();
    bigrams = struct();
    trigrams = struct();
    
    % unigrams
    for i=1:length(words)
        f = words{i};
        if isfield(unigrams, f)
            unigrams.(f) = unigrams.(f) + 1;
        else
            unigrams.(f) = 1;
        end
    end

    % bigrams
    for i=1:length(words)-1
        f = words{i};
        s = words{i+1};
        if isfield(bigrams, f) == 0
            bigrams.(f).(s) = 1;
        else
            if isfield(bigrams.(f), s) == 0
                bigrams.(f).(s) = 1;
            else
                bigrams.(f).(s) = bigrams.(f).(s) + 1;
            end
        end
    end
    
    % trigrams
    for i=1:length(words)-2
        f = words{i};
        s = words{i+1};
        t = words{i+2};
        if isfield(trigrams, f) == 0
            trigrams.(f).(s).(t) = 1;
        else
            if isfield(trigrams.(f), s) == 0
                trigrams.(f).(s).(t) = 1;
            else
                if isfield(trigrams.(f).(s), t) == 0
                    trigrams.(f).(s).(t) = 1;
                else
                    trigrams.(f).(s).(t) = trigrams.(f).(s).(t) + 1;
                end
            end
        end
    end
end

