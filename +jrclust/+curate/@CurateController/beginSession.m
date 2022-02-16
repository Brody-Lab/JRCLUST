function beginSession(obj)
    %BEGINSESSION Start curating clusters
    if ~isempty(obj.hFigs) % session already running
        return;
    end

    obj.isEnding = 0;
    obj.cRes = struct('hClust', obj.hClust);
    obj.maxAmp = obj.hCfg.maxAmp;
   
    % preferred order for Brody Lab sorting
    obj.reorderSites(obj.hCfg.siteLoc(:,2) + obj.hCfg.shankMap*2*max(obj.hCfg.siteLoc(:,2)))    ;
    obj.reorderClusters('clusterSites');    
    
    % select first cluster
    obj.selected = 1;
    obj.currentSite = obj.hClust.clusterSites(1);
    
    obj.plotAllFigures();
    
    % initiate delete auto on start - brody lab specific
    obj.autoDelete();
    
end