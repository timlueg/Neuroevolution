function [gewichtsmatrix] = phenotyp(nodeList,connectionList)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

size_knoten = size(nodeList,1);
size_connections = size(connectionList,1);

index = find(connectionList(:,4));
connectionList=connectionList(index,:);

gewichtsmatrix = zeros(nodeList,nodeList);

indexGewichtsmatrix= sub2ind(size(gewichtsmatrix),connectionList(:,1),connectionList(:,2));
%in einer Spalte der Gewichtsmatrix stehen alle Inputgewichte des Knoten,
%Knoten der in der Spalte repräsentiert wird.

gewichtsmatrix(indexGewichtsmatrix)=connectionList(:,3);

% for i=1:size_connections
%     if connectionList(i,4)
%         gewichtsmatrix(connectionList(i,1),connectionList(i,2))= connectionList(i,3);
%     end
% end

end

