%
%  evalPerplexity
%  Zi Mo Su
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 3. 

trainDir = '/u/cs401/A2_SMT/data/Hansard/Training';
testDir = '/u/cs401/A2_SMT/data/Hansard/Testing';

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train(trainDir, 'e', 'lm_e.mat');
LMF = lm_train(trainDir, 'f', 'lm_f.mat');

disp('For no smoothing:')
disp(['English : ' num2str(perplexity(LME, testDir, 'e', '', 0))])
disp(['French  : ' num2str(perplexity(LMF, testDir, 'f', '', 0))])

disp('For delta=0.2:')
disp(['English : ' num2str(perplexity(LME, testDir, 'e', 'smooth', 0.2))])
disp(['French  : ' num2str(perplexity(LMF, testDir, 'f', 'smooth', 0.2))])

disp('For delta=0.4:')
disp(['English : ' num2str(perplexity(LME, testDir, 'e', 'smooth', 0.4))])
disp(['French  : ' num2str(perplexity(LMF, testDir, 'f', 'smooth', 0.4))])

disp('For delta=0.6:')
disp(['English : ' num2str(perplexity(LME, testDir, 'e', 'smooth', 0.6))])
disp(['French  : ' num2str(perplexity(LMF, testDir, 'f', 'smooth', 0.6))])

disp('For delta=0.8:')
disp(['English : ' num2str(perplexity(LME, testDir, 'e', 'smooth', 0.8))])
disp(['French  : ' num2str(perplexity(LMF, testDir, 'f', 'smooth', 0.8))])

disp('For delta=1.0:')
disp(['English : ' num2str(perplexity(LME, testDir, 'e', 'smooth', 1.0))])
disp(['French  : ' num2str(perplexity(LMF, testDir, 'f', 'smooth', 1.0))])

