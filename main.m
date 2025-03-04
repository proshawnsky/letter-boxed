% Setup
clc; clear; close all;
fileName = 'words_alpha.txt';
FID = fopen(fileName);
data = textscan(FID,'%s');
fclose(FID);
all_words = string(data{:});

%% Get and print letters on walls
tab = '\t';
tab2 = [tab tab];
tabBar = [tab '|' tab];
bar = '|';
space = ' ';

%default values
wall_1 = ['x', 'e', 'r']; %left
wall_2 = ['h', 's', 'n']; %top
wall_3 = ['a', 'b', 'c']; %right
wall_4 = ['k', 'i', 'm']; %bottom

txt = input('Type in all 12 letters, one edge of the box at a time, with or without spaces. Press Enter when done.\n','s');
txt = erase(lower(txt),' ');
if length(txt) ~= 12
    warning('12 Characters not entered correctly. Using default values.');
    walls = [wall_1; wall_2; wall_3; wall_4]';
else
    walls = reshape(txt,3,4);
end

wall_1 = walls(:,1); wall_2 = walls(:,2); wall_3 = walls(:,3); wall_4 = walls(:,4); 

fprintf(['\n' tab2   wall_2(1)   tab     space wall_2(2)   tab space    wall_2(3) '\n'])
fprintf([tab    space space space '-------------\n']) 
fprintf([tab    wall_1(1)   space bar  tab2 tab2 bar space wall_3(1) '\n'])
fprintf([tab    space       space bar  tab2 tab2 bar space space '\n'])
fprintf([tab    wall_1(2)   space bar  tab2 tab2 bar space wall_3(2) '\n'])
fprintf([tab    space       space bar  tab2 tab2 bar space space '\n'])
fprintf([tab    wall_1(3)   space bar  tab2 tab2 bar space wall_3(3) '\n'])
fprintf([tab    space space space '-------------\n']) 
fprintf([tab2   wall_4(1) tab space wall_4(2) tab space wall_4(3) '\n']);

%% Math time

all_words = all_words(strlength(all_words)>2);
valid_words = [];
tic;
for j = 1:length(all_words)
    word = all_words(j);
    found = 1;
    location = 0;
    i = 1;
    while i <= length(word{:})
         [present, location] = ismember(word{:}(i), returnWithMissingColumn(walls,location));
         if present
             i = i + 1;
         else
             i = length(word{:}) + 1;
             found = 0;
         end
    end
    if found
        valid_words = [valid_words, word]; %#ok<AGROW>
    end
end

%% Use valid words to find solution sequences

foundSequences = 0;
valid_words = ['', valid_words];

for i = 2:length(valid_words)
    firstWord = valid_words(i);
    
    secondWords = valid_words(startsWith(valid_words, firstWord{1}(end)));
    for j = 1:length(secondWords)
        phrase = firstWord + secondWords(j);
        completeSequence = all(ismember(walls, phrase{:})); % True if all letters are used!
        if completeSequence
%             fprintf(firstWord + tab2 + secondWords(j) + '\n');
            fprintf('%-12s \t %-12s\n',firstWord, secondWords(j));
            foundSequences = foundSequences + 1;
        end
    end
end

time = toc;
fprintf('\nFound %d valid solutions in %.3f seconds\n\n', foundSequences, time);

function wallsOut = returnWithMissingColumn(walls, currentIdx)
    
    if currentIdx == 0
        wallsOut = walls;
        return;
    elseif currentIdx < 4
        range = 1:3;
    elseif currentIdx < 7
        range = 4:6;
    elseif currentIdx < 10
        range = 7:9;
    else 
        range = 10:12;
    end
    walls(range) = ' ';
    wallsOut = walls;
    
end

% 1-3           -> 4, 5, 6, 7, 8, 9, 10, 11, 12
% 4-6           -> 1, 2, 3, 7, 8, 9, 10, 11, 12
% 7-9           -> 1, 2, 3, 4, 5, 6, 10, 11, 12
% 10-12         -> 1, 2, 3, 4, 5, 6, 7,   8,  9
