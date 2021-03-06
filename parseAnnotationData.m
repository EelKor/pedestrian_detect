% parseAnnotationData.m 
% 딥러닝 학습파일 파싱 스크립트 
% 해당 디렉토리의 \Train 에 있는 데이터를 매트랩에서 학습 할 수 있도록 가공

% 작성자 : 경상국립대학교 기계융합공학과 이승신(2018013246)
% 작성일 : 2021-10-15 

% 목 적
% 딥러닝을 위한 학습데이터 가공
% 해당 디렉토리의 annotation.txt 파일 파싱
% , 로 구분된 데이터파일 annotation.txt 를 매트랩에서 활용 할수 있도록 함


clc
clear

mycell = cell(1,2);
% 파일 이름 입력
filename = 'annotations.txt';
tables = readtable(filename,'TextType','string');    % 해당 파일을 table 형식으로 읽어옴

% tables 의 모든 행에 대해
for idx = 1:height(tables)
  tmp = zeros(1,4);     % Boundbox 좌표를 담기 위한 임시 행렬
  
  % annotations 행의 모든 열
  for boundBoxcoord = 2:width(tables)-1
    if ~ismissing(tables{idx,boundBoxcoord})     % 해당 열이 비어있지 않으면 BoundBox 값이 있는것으로 간주
        tmp = [tmp; str2num(tables{idx,boundBoxcoord})];     % 임시행렬에 Boundbox 값 추가
    end
  end
  tmp(1,:) = [];        % 24행 에서 생긴 맨 앞의 빈 행 삭제
  celltmp = {tables{idx,1},tmp};
  mycell = [mycell; celltmp];
end

mycell(1,:) = [];       % 17행 에서 생긴 맨 앞의 빈 셀 삭제
newTable = cell2table(mycell, 'VariableNames',{'imageFilename','vehicle'})      % 셀 배열을 테이블 형식으로 변환

% 생성된 데이터 저장
save('pedestrianDataset.mat','newTable')


