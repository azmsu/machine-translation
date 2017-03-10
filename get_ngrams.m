function [unigrams, bigrams, trigrams] = get_ngrams(words)
    
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

    
    