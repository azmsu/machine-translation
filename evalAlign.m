%
%  evalAlign
%  Zi Mo Su
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = 'A2_SMT/data/Hansard/Training';
testDir      = 'A2_SMT/data/Hansard/Testing';
fn_LME       = 'lm_e.mat';
fn_LMF       = 'lm_f.mat';
lm_type      = '';
delta        = 0.0;
cap          = Inf;

% Train your language models. This is task 2 which makes use of task 1
% LME = lm_train(trainDir, 'e', 'lm_e.mat');
% LMF = lm_train(trainDir, 'f', 'lm_f.mat');

vocabSize = length(fields(LME.uni));

% Train your alignment model of French, given English 
% AM_1 = align_ibm1(trainDir, 1000, 10, 'am_1.mat');
% AM_10 = align_ibm1(trainDir, 10000, 10, 'am_10.mat');
% AM_15 = align_ibm1(trainDir, 15000, 10, 'am_15.mat');
% AM_30 = align_ibm1(trainDir, 30000, 10, 'am_30.mat');

fre_file = textread('A2_SMT/data/Hansard/Testing/Task5.f', '%s', 'delimiter', '\n');
ref1_file = textread('A2_SMT/data/Hansard/Testing/Task5.google.e', '%s', 'delimiter', '\n');
ref2_file = textread('A2_SMT/data/Hansard/Testing/Task5.e', '%s', 'delimiter', '\n');

% loop through sentences
for i=1:length(fre_file)

    
    fre = preprocess(fre_file{i}, 'f');
    ref1 = preprocess(ref1_file{i}, 'e');
    ref2 = preprocess(ref2_file{i}, 'e');
    disp('Translating: ')
    disp(fre(11:end-8))
    disp('Google:')
    disp(ref1(11:end-8))
    disp('Hansard:')
    disp(ref2(11:end-8))
    % decode the test sentence 'fre'
    cand_1 = decode2(fre, LME, AM_1, '', delta, vocabSize);
    cand_10 = decode2(fre, LME, AM_10, '', delta, vocabSize);
    cand_15 = decode2(fre, LME, AM_15, '', delta, vocabSize);
    cand_30 = decode2(fre, LME, AM_30, '', delta, vocabSize);
    
    cands = {cand_1, cand_10, cand_15, cand_30};
    AMs = {'1000', '10000', '15000', '30000'};
    
%     disp(['Ref (Google)  : ' ref1])
%     disp(['Ref (Hansard) : ' ref2])
    for j=1:4
        [bleu1, bleu2, bleu3] = bleu(cands{j}, ref1, ref2, cap);
        disp(['Trained model ' AMs{j}])
        disp(cands{j}(8:end-7))
        bleu_n1 = bleu1
        bleu_n2 = bleu2
        bleu_n3 = bleu3
        %disp(['     BLEU     n=1: ' num2str(bleu1) '     n=2: ' num2str(bleu2) '     n=3: ' num2str(bleu3)])
    end
    disp(' ')
end

