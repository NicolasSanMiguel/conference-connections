% Nicolas San Miguel
% May 2023

%                               Description
%       This takes in the Insitute of Navigation (ION) program .pdf 
% file for a given conference, parses through each presentation and
% separates each presentation by title, author, and affiliation. Then, 
% each pair of authors/organizations, are added to a graph as 
% nodes/edges. After some cleaning, the connections are plotted together.

clc; clear; close all

% OVERALL NOTES:
%   * doesn't include the alternate presentations
% Some parsing problems:
%   * if a title has a comma, part of it may be included as
%       an author/org name
%   * sometimes two authors' names are combined
%   * orgs are listed multiple times if listed with different spellings
%   * still have to parse all datetimes out of strings, sometimes included


tic
% % % % % % % % % % step 1: extract text from the pdf
filename = "PLANS23Program.pdf";
filename = "GNSS23Program.pdf";
str = extractFileText(filename); % may require a MATLAB Toolkit
toc % can take up to a minute to run dep. on the size of the PDF

% % % % % % % % % % step 2: clean data into lists of authors and titles
% separate the one long string by newline characters
all_txt_lines = strsplit(str, '\n');

% Extract the substrings that begin with a time in
% the form X:XX using regular expression.
time_pattern1 = '\d{1}:\d{2}\.';
output_cell = regexp(all_txt_lines, time_pattern1);

% returns the indices of all elements that begin with
% a time of X:XX or XX:XX.
indices = find(cellfun(@(x) ~isempty(x) && ...
    (x(1) == 1 || x(1) == 2), output_cell));

% if the jump between two indices is 1 (or 2), then a line of text
% probably got cut out, so this adds it back in: i.e. the title indices:
% 321, 323, 325 -> {321,322},{323,324},{325,326}
lines_of_interest = {};
indices(end+1) = 0; % to avoid going out of bounds
indices(end+2) = 0; % to avoid going out of bounds
for i = 1:length(indices)-2
    curr_idx = indices(i);
    next_idx = indices(i+1);
    if next_idx == curr_idx+2
        lines_of_interest{i} = strcat(all_txt_lines(curr_idx),...
            all_txt_lines(curr_idx+1));
    elseif next_idx == curr_idx+3
        lines_of_interest{i} = strcat(all_txt_lines(curr_idx),...
            all_txt_lines(curr_idx+1),all_txt_lines(curr_idx+2));
    end
end
lines_of_interest = lines_of_interest(~cellfun(...
    'isempty',lines_of_interest));
% ^^ in this var, each line has time, title, and all authors/affiliations

% separate each line into titles & authors/affiliations
authors = {};
for i = 1:length(lines_of_interest)
    curr_line = lines_of_interest{i};
    % remove the presentation times from the beginning. They are
    % of the form X:XX a.m. - X:XX a.m. (or XX:XX or p.m.)
    temp = regexp(curr_line, '\d+\.\s', 'split');
    lines_of_interest{i} = temp(2);
    no_spaces = strtrim(temp(2)); % remove leading and trailing space
    % removes spaces and the word "and"
    title_n_authors = split(no_spaces, [",",";"]);
    strarr = erase(title_n_authors(2:end),["and"," ","\d{2}:\d{2}-\d{2}:\d{2}"]);

    [auth1,auth2] = pad_string_arrays(authors, strarr);
    authors = [auth1,auth2]; % all the authors
    title = title_n_authors(1); % not used but  here
end

% % % % % % % % % % step 3: make a graph of all authors & affiliations
% Create a graph
G = graph();
G = addnode(G, "empty");

% Loop over each paper and add everyone as a node
for i = 1:size(authors,2)
    % Get the list of authors for this paper
    author_list = authors(:,i);
    author_table = cell2table(cellstr(author_list),...
        'VariableNames', {'Name'});

    % Add each author to the graph if they're not already in it
    for j = 1:length(author_list)
        if ~ismember(author_table(j, :), G.Nodes)
            G = addnode(G, author_list{j});
        end
    end

    % Connect each pair of authors in the list
    for j = 1:length(author_list)-1
        for k = j+1:length(author_list)
            G = addedge(G, author_list{j}, author_list{k});
        end
    end
end

% % % % % % % % % % step 4: Remove extraneous things and plot the graph
% Note: some titles were split if there were commas, some empty node names
nodes2remove = ["Sensetivity","Robustness","","empty","Classification",...
    "Break.RefreshmentsinExhibitHall"];
G = rmnode(G,nodes2remove);

% Remove self loops
G = rmedge(G, 1:numnodes(G), 1:numnodes(G));

% Plot the graph
p = plot(G);

% Highlight nodes and edges
nSU = neighbors(G,"StanfordUniversity");

highlight(p,"StanfordUniversity",'NodeColor',[0 0.75 0])
highlight(p,nSU,'NodeColor','red')
highlight(p,"StanfordUniversity",nSU,'EdgeColor','red')


