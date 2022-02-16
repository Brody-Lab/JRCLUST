function reorderSites(obj, order)
    %REORDERSITES Reorder sites according to specified geometry
    if issorted(obj.channel_idx(obj.hClust.clusterSites))
        clusters_sorted_by_center_site = true;
    else
        clusters_sorted_by_center_site = false;
    end
    [~,obj.spatial_idx] = sort(order);
    if clusters_sorted_by_center_site
        obj.reorderClusters('clusterSites');
    end
end

