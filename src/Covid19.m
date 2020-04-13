function outTable=Covid19(filePop,fileFlux,fileFAviao,fileBet,fileCod,fileSus,fileOut,IntervFlux,IntervFluxLock,IntervR0,nTop,ssa,T, titulo,cen,lockMun,flagVideo,data,estados)
%% carrega arquivos de entrada
Pop=readtable(filePop);
N=length(Pop.id);                   % Quantidade de municipios
ssa=find(Pop.id==ssa);
Flux=readtable(fileFlux);
Flux.Flux=Flux.Flux/7;          % Divide por 7 pois dados s�o semanais
betaTb=readtable(fileBet);      % beta e gamma de cada estado
codTb=readtable(fileCod);       % c�digos ibge de cada estado
susTb=readtable(fileSus);       % Popula��o estimada de suscept�veis por munic�pio

if ~isempty(fileFAviao)
    Aviao=readtable(fileFAviao);
    Aviao.Pax=Aviao.Pax/365;        % Divide por 365 pois dados s�o anuais
else
    Aviao=[];
end

mFlux=doMatFlux(Pop,Flux,Aviao);    % Monta a matriz de fluxo terrestre e a�reo
[Pop.Ps,Pop.Pr]=loadSus(Pop,susTb,data);          % Carrega suscept�veis estimados

%%


                % PARAMETROS DO MODELO
Flg_trans=1;                    % Flag 1=considera fluxo 0=Para o fluxo entre todos os munic�pios
[beta,gamma]=montaBeta(betaTb,codTb,Pop);   %monta vetor com os betas e gammas para todos os munic�pios
beta=beta*IntervR0;
if ~isempty(estados)
    iEs=find(ismember(Pop.UF,estados));
    Nr=length(iEs);
else
    iEs=1:N;
    Nr=N;
end

if length(lockMun) > 0
    locs=find(ismember(Pop.id,lockMun));
    mFluxA=mFlux;
    mFlux=mFlux*IntervFlux;         % aplica interven��o sobre toda a matriz
    for h=1:length(locs)            % aplica interven��o especial nos municipios locks
       mFlux(:,locs(h))=mFluxA(:,locs(h))*IntervFluxLock;
       mFlux(locs(h),:)=mFluxA(locs(h),:)*IntervFluxLock;
    end
else
    mFlux=mFlux*IntervFlux;
end

Sps=zeros(T,1);
Spi=Sps;
Spr=Spi;
tS=zeros(T,1);                  % Total de suscet�veis
tI=zeros(T,1);                  % Total de Infectados
tR=zeros(T,1);                  % Total de Recuperados
MIn=zeros(T,1);                 % Qauntidade de munic�pios com mais de 1 caso
TopK=zeros(T,nTop);             % array temporal com o Top N mais infectados

vidName=fileOut;
if flagVideo
    figure(1);
    set(gcf, 'Position', get(0,'ScreenSize'));

    % Colormap
    n = 50;               %// number of colors
    R = linspace(0,1,n);  %// Red from 1 to 0
    G = zeros(size(R));  %// green from 0 to 1
    B = linspace(1,0,n);   %// blue all zero
    map = [R(:), G(:), B(:)];

    CovidVideo = VideoWriter(vidName); %open video file
    CovidVideo.FrameRate = 5;  %can adjust this, 5 - 10 works well for me
    open(CovidVideo);
end
outTable=table('Size',[Nr*T 6],'VariableTypes',{'uint32','uint16','uint64','double','uint16','char'},'VariableNames',{'Geocode', 'dia','Infec','Perc','cenario','UF'});
%outTable=table();

tic;
lt=1;
for time=1:T                    % La�o temporal
    Sps(time)=Pop.Ps(ssa);      % Separa as popula��es de Salvador
    Spi(time)=Pop.Pi(ssa);
    Spr(time)=Pop.Pr(ssa);

    tS(time)=sum(Pop.Ps(iEs));
    tI(time)=sum(Pop.Pi(iEs));
    tR(time)=sum(Pop.Pr(iEs));
    MIn(time)=sum(Pop.Pi(iEs)>=0.99);
    [~,im]=maxk(Pop.Pi,nTop);
    TopK(time,:)=Pop.id(im);    % guarda o Top N

    if flagVideo && ( time==1 || mod(time,2)==0)
        report(Pop,time,tS,tI,tR,Sps,Spi,Spr,MIn,ssa,im, titulo,map);                   % Gera a sa�da dos gr�ficos
        frame = getframe(gcf); %get frame
        writeVideo(CovidVideo, frame);
    end
    if (~flagVideo) && (mod(time,10)==0)
        disp(time);
        toc;
    end


    tt=repmat(time,N,1);
    cenario=repmat(cen,N,1);
    infec=floor(Pop.Pi);
    if time > T/2
        infec(infec<2)=0;
    end
    perc=infec./Pop.Pt*100;
    outTable(lt:lt+Nr-1,:)=[num2cell([Pop.id(iEs) tt(iEs) infec(iEs) perc(iEs) cenario(iEs)]) Pop.UF(iEs)];
    lt=lt+Nr;


    PsA=Pop.Ps; PiA=Pop.Pi;
    PrA=Pop.Pr;PtA=Pop.Pt;      % Guarda popula��o atual para garantir passagem de tempo igual a todos munic�pios
    if Flg_trans
        [PsA,PiA,PrA,PtA]=runFlux_mex(mFlux,Pop.Ps,Pop.Pi,Pop.Pr,Pop.Pt,PsA,PiA,PrA,PtA);         % Atualiza o fluxo de pessoas
    end
    %disp('Flux');toc;tic;
    [PsA,PiA,PrA]=runEdo(beta,gamma,Pop,PsA,PiA,PrA);                   % Roda modelo EDo para todos os munic�pios
    Pop.Ps=PsA; Pop.Pi=PiA;
    Pop.Pr=PrA;Pop.Pt=PtA;      % Atualiza vetor de popula��o ap�s fluxo e EDO
    %disp('Edo');
end
if flagVideo
    close(CovidVideo);
end

outTable=sortrows(outTable,2);

dia=(1:T)';
tS=floor(tS);tI=floor(tI);tR=floor(tR);
totTable=table(dia,tS,tI,tR,MIn,TopK);
outName=[ fileOut 'Serie.csv'];
writetable(totTable,outName,'Delimiter',',');
end
