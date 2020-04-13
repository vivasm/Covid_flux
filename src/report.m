function report(Pop,time,tS,tI,tR,Sps,Spi,Spr,MIn,ssa,im,titulo,map)


TSalv=Pop.Pi(ssa)+Pop.Ps(ssa)+Pop.Pr(ssa)-Pop.Pt(ssa);
disp([num2str(time) ' ' num2str(Pop.Ps(ssa)) ' ' num2str(Pop.Pi(ssa)) ' ' ...
    num2str(Pop.Pr(ssa))  ' ' num2str(MIn(time))...
    ' ' num2str(TSalv)]);


Infec=floor(Pop.Pi);
vt=1:time;
figure(1);
subplot(2,4,[1 2]);
plot(vt,Spi(1:time),vt,tI(1:time));
title('Previsão de infectados');
xlabel('dias');
ylabel('Número de infectados');
legend({Pop.Name{ssa},titulo},'Location','northwest');
subplot(2,4,5);
bar(Infec);
text(im(1),Infec(im(1)),Pop.Name(im(1)));
text(im(2),Infec(im(2)),Pop.Name(im(2)));
text(im(3),Infec(im(3)),Pop.Name(im(3)));
title('Top3 Infectados');


subplot(2,4,6);
plot(vt,MIn(1:time));
title('Municip.c/casos>1');
xlabel('dias');
subplot(2,4,[3 4 7 8]);
id=find(Infec>=2);
Infec=Infec(id);
la=Pop.Lat(id);
lo=Pop.Lon(id);
colormap(map);
[~,tt]=sortrows(Infec,'ascend');
geoscatter(la(tt),lo(tt),Infec(tt)/500+5,Infec(tt),'DisplayName','Infectados');
c = colorbar;
c.Label.String = 'casos';
drawnow;

end

