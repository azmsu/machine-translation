function outSentence = preprocess( inSentence, language )
%
%  preprocess
%  Zi Mo Su 
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz

    global CSC401_A2_DEFNS
    currDir = cd;
    cd('A2_SMT/code')
    csc401_a2_defns
    
    % first, convert the input sentence to lower-case and add sentence marks 
    inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower(inSentence) ' ' CSC401_A2_DEFNS.SENTEND];

    % trim whitespaces down 
    inSentence = regexprep(inSentence, '\s+', ' '); 

    % initialize outSentence
    outSentence = inSentence;

    % perform language-agnostic changes
    outSentence = regexprep(outSentence, '[.?,!:;)(+-<>="]', ' $& ');
    
    switch language
        case 'e'
            outSentence = regexprep(outSentence, 'n''', ' $&');
            outSentence = regexprep(outSentence, '([^n])('')', '$1 $2');

        case 'f'
            outSentence = regexprep(outSentence, '(\s)(l'')', ' $2 ');
            outSentence = regexprep(outSentence, '(\s)(d'')(?!(abord|accord|ailleurs|habitude))', ' $2 ');
            outSentence = regexprep(outSentence, '(\s)([^aeiould]'')', ' $2 ');
            outSentence = regexprep(outSentence, '(\s)(qu'')', ' $2 ');
            outSentence = regexprep(outSentence, '(\S'')(on|il)(\s)', '$1 $2 ');

    end

    % change unpleasant characters to codes that can be keys in dictionaries
    outSentence = regexprep(outSentence, '\s+', ' ');
    outSentence = convertSymbols(outSentence);
    cd(currDir)