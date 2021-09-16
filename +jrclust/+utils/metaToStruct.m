function S = metaToStruct(filename)
    %METATOSTRUCT read a SpikeGLX meta file and convert to struct
    [status, cmdout] = system(sprintf('file %s', filename));

    % check given file is a text file
    if status == 0
        assert(any(strfind(lower(cmdout), 'text')), '''%s'' is not a text file', filename);
    else % fall back to extension checking
        [~, ~, ext] = fileparts(filename);
        assert(strcmpi(ext, '.meta'), '''%s'' is not a meta file', filename);
    end

    %% below code replaces old parsing code that used textscan. This is robust to the lines inserted into spikeGLX meta files by catGT.
    txt = readlines(filename);
    equals_place = strfind(txt,'=');
    count=0;
    for i=1:length(txt)
        if numel(equals_place{i})
            count=count+1;
            keys{count} = txt{i}(1:equals_place{i}(1)-1);
            vals{count} = txt{i}(equals_place{i}(1)+1:end);
        end
    end

    S = struct();

    for i = 1:numel(keys)
        key = keys{i};
        if key(1) == '~'
            key(1) = [];
        end
        
        try
            eval(sprintf('%s = ''%s'';', key, vals{i}));
            switch key
                case {'acqMnMaXaDw', 'snsMnMaXaDw', 'acqApLfSy', 'snsApLfSy'}
                    eval(sprintf('%s = cellfun(@str2double, strsplit(%s, '',''));', key, key));

                otherwise
                        eval(sprintf('num = str2double(%s);', key));
                        if ~isnan(num)
                            eval(sprintf('%s = num;', key));
                        end
            end

            eval(sprintf('S = setfield(S, ''%s'', %s);', key, key));
        catch ME
            error('error reading %s: %s', filename, ME.message);
        end
    end
end

