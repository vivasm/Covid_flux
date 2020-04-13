%-----------------------TESTE
clear all;
resultPath=['results' filesep 'CE' filesep];
arqPop=['data' filesep 'popBR_2020-04-08.xlsx'];         % quantidade de infectados por munic�pio
arqBet=['data' filesep 'estado_sumario_07-04-20.csv'];   % arquivo com os betas e gamma de cada estado
arqSus=['data' filesep 'municipios_07-04-20.csv'];           % arquivo com os valores estimados de suseptiveis
data='07/04/2020';

arqFlu=['data' filesep 'FluxBR.xlsx'];                   %Fluxo hidro e rodovi�rio
arqAvi=['data' filesep 'AviaoBR.xlsx'];                  %Fluxo a�reo
arqCod=['data' filesep 'codBR.xlsx'];                    % C�digo IBGE de cada estado

addpath('src')                                           % path de códigos-fonte

Ssa=2927408;
nTop=3;
T=200;
Titulo='Nordeste';
vetFlux=[1,0.4];
vetFluxLock=[1,0.05];
vetRo=[2,1];
flagVideo=0;
% Munic�pios em que ser�o aplicadas a redu��o do fluxo, caso vazio aplica em todos
lockMun=[2900702,2902708,2903201,2903904,2904605,2905701,2906204,2906501,2907509,2908002,2908507,2909307,2910057,2910503,2910800,2911709,2913606,2913903,2914802,2914901,2915205,2915502,2915601,2916104,2917102,2918001,2918407,2919207,2919553,2921104,2922904,2925204,2925303,2925501,2927408,2928109,2928950,2930709,2931350,2933208,2933307];
estados={'AL','BA','CE','MA','PB','PE','PI','RN','SE'};   % estados para sa�da de relat�rios

% ----------Cen�rios
mkdir(resultPath);
Tb=table();
cen=1;
for i=1:length(vetFlux)
        outName=[resultPath Titulo num2str(vetFlux(i),2) '_' num2str(vetFluxLock(i),2) '_' num2str(vetRo(i),2) ...
            '_' num2str(vetFluxLock(i),2)];
        Ta=Covid19(arqPop,arqFlu,arqAvi,arqBet,arqCod,arqSus, outName,vetFlux(i),vetFluxLock(i),vetRo(i),nTop,Ssa,T,Titulo,cen,lockMun,flagVideo,data,estados);
        Tb=[Tb;Ta];
        cen=cen+1;
end
outName=[resultPath Titulo '.csv'];
writetable(Tb,outName,'Delimiter',',');
