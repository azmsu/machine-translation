function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
%  Zi Mo Su
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

    % some rudimentary parameter checking
    if (nargin < 2)
        disp( 'lm_prob takes at least 2 parameters');
        return;
    elseif nargin == 2
        type = '';
        delta = 0;
        vocabSize = length(fieldnames(LM.uni));
    end
    
    if (isempty(type))
        delta = 0;
        vocabSize = length(fieldnames(LM.uni));
    elseif strcmp(type, 'smooth')
        if (nargin < 5)  
            disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
            return;
        end
        if (delta <= 0) or (delta > 1.0)
            disp( 'lm_prob: you must specify 0 < delta <= 1.0');
            return;
        end
    else
        disp( 'type must be either '''' or ''smooth''' );
        return;
    end

    words = strsplit(' ', sentence);
    logProb = 0;
    
    % get bigrams
    for i=1:length(words)-1
        first_word = words{i};
        second_word = words{i+1};
        
        if isfield(LM.bi, first_word)
            if isfield(LM.bi.(first_word), second_word)
                logProb = logProb + log2((LM.bi.(first_word).(second_word) + delta)/(LM.uni.(first_word) + delta*vocabSize));
            else
                if delta == 0
                    logProb = -Inf;
                    return
                end
                logProb = logProb + log2(delta/(LM.uni.(first_word) + delta*vocabSize));
            end
        else
            if delta == 0
                logProb = -Inf;
                return
            end
            logProb = logProb + log2(delta/(delta*vocabSize));
        end
    end
    
    return