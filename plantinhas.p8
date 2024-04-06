pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--ed rocha te amo ==============
function _init()cu
 --inicia o mouse
 poke(0x5f2d, 1)
 --cus =========================================================================
 espacamento  = 0

 cu1 = nil
 cu2 = nil
 cu3 = nil
 cu4 = nil
 cu5 = nil
 cu6 = nil
 cu7 = nil
 cu8 = nil
 cu9 = nil

 str1 = ""
 str2 = ""
 str3 = ""
 str4 = ""
 str5 = ""
 str6 = ""
 str7 = ""
 str8 = ""
 str9 = ""
	
 --[[
 status
 1 para a tela principal
 2 para loja
 3 para o deposito
 ]]
 status = 1

 --auxiliares
 aux_tipo  = 1
 saldo     = 8000
 grav      = 1.75
 atl_wait  = false
 timer_atl = 0
		
 --init de selecao
 sel_tst ={["val"]=false,["qual"]=nil}
 sel_vas ={["val"]=false,["qual"]=nil}
 sel_bts ={["val"]=false,["qual"]=nil}
 sel_esp ={["val"]=false,["qual"]=nil}
 sel_car ={["val"]=false,["qual"]=nil}
 sel_buy ={["val"]=false,["qual"]=nil}
 sel_inv ={["val"]=false,["qual"]=nil}
 sel_atl ={["val"]=false,["qual"]=nil}
 sel_jrd ={["val"]=false,["qual"]=nil}
 atribui ={["val"]=false,["atl"]={}}	
 semear  ={["val"]=false,["qual"]={}}	

 --listas
 ls_tst     = {["tipo"]="teste"}
 ls_vas     = {["tipo"]="vaso"}
 ls_bts     = {["tipo"]="botao"}
 ls_esp     = {["tipo"]="espaco"}
 ls_plv     = {["tipo"]="palavra"}
 ls_car     = {["tipo"]="carrinho"   ,["total" ]=0 ,["coisas"]={}   }
 ls_atl     = {["tipo"]="atalho"     ,["atls"  ]={},["show"  ]=false} 
 ls_inv     = {["tipo"]="inventario" ,["coisas"]={}}
 ls_jrd     = {["tipo"]="jardim"     ,["coisas"]={}}
 ls_prt     = {["tipo"]="prateleiras"}
 ls_vas_atv = {["tipo"]="vaso com planta"}

 --listas de particulas
 pat_sem = {["tipo"]="particulas sementes"}

 --init de palavras
 p1={192,193,193,194,240}
 p2={208,193,192,240}
 p3={208,194,195,209,192,240} 
 p4={210,194,193,241,211,224,240}
 p5={208,224,227,243,211}
 p6={225,226,242}
 p7={244,245,246}
 tools   = init_palavra(11, 4 ,p1)
 pots    = init_palavra(11,32 ,p2)
 plants  = init_palavra(11,60 ,p3)
 flowers = init_palavra(11,88 ,p4)
 price   = init_palavra(17,120,p5)
 buy     = init_palavra(99,118,p6) 
 buy_atv = init_palavra(99,118,p7) 
 
 --instancias ===================
 
 --cursor
 mouse = criar_obj("mouse",0)
	
 --botoes
 bt_loja = criar_obj("botao",1)
 bt_volt = criar_obj("botao",2)
 bt_comp = criar_obj("botao",3)
 bt_dept = criar_obj("botao",4)	
 bt_skip = criar_obj("botao",5)	

 --espacos da lojinha
 for i=1,4 do criar_esps(4) end
 
	enfileirar_esp(ls_esp[1],11,10)
	enfileirar_esp(ls_esp[2],11,38)
	enfileirar_esp(ls_esp[3],11,66)
	enfileirar_esp(ls_esp[4],11,94)
 
 //atalhos
	init_atl()
	
	//prateleiras
	criar_prateleiras(4)
	
	--testes @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	ls_teste = {}
	vaso_change = 5
 que_planta  = 9
 aux_x = 10
	for i=1, 4 do
		add_um_item(criar_obj("item",vaso_change,nil,5 ,80),1)
		vaso_change += 1
		if(vaso_change>8)vaso_change=5
 	ls_jrd.coisas[i].planta = (criar_obj("item",que_planta)).fases
		que_planta += 1
		ls_jrd.coisas[i].x = aux_x
 	add(ls_vas_atv,ls_jrd.coisas[i])
  aux_x += 20
	end



	



end

--update ===========================================================================================================+
function _update()
 mouse:att()
 cool_down(10)
 if(not ls_atl.show) att_particulas(pat_sem)
 --jogo principal rocha --------------------------------------------------------------------------------------------+	
 if(status == 1)then
  if(not semear.val)toggle_atl()	
  --ir depot .......................................................................................................
  if(ls_atl.show)then
   bt_dept:hover()
   bt_dept:ativa()
  end
  --ir loja ........................................................................................................   
  if(not semear.val)then
   bt_loja:hover()
   bt_loja:ativa()
  end
  bt_skip:hover()
  bt_skip:ativa()
 	
  --atribuir pra qual atl
  if(not sel_atl.val and ls_atl.show) then
   sel_atl.qual = check_sel(sel_atl,ls_atl.atls,"circ")	 
  end
 
  if(sel_atl.qual != nil)then
   toggle_atribuir(sel_atl.qual)
  end
  
  if(atl_wait and not semear.val) remov_atl()
  
  --mover coisas
  if(not sel_jrd.val and not ls_atl.show) then
   sel_jrd.qual = check_sel(sel_jrd,ls_jrd.coisas,"retg")	 
  end
 	
  if(sel_jrd.qual != nil)then		
   if(not atribui.val and not semear.val)then
    sel_jrd.qual:mov_cur_esq(sel_jrd,"retg")	
   elseif(atl_wait and not semear.val)then
	atribuicao()
   end
  end
 	
  --se esta esperando semente
  if(semear.val and not atribui.val)then
   plantar(semear.qual)		
  end
 	
 --lojinha rocha ---------------------------------------------------------------------------------------------------+				
 elseif(status == 2)then
  --selecionar loja ................................................................................................+
  if(not sel_esp.val) then
   for i in all(ls_esp) do
    sel_esp.qual = check_sel(sel_esp,i,"retg")								
    if(sel_esp.qual != nil) break		
   end
  end 
  
  --adicionar ao carrinho...........................................................................................+
  if(sel_esp.qual != nil and sel_esp.val)then	
   sel_esp.qual:hover(sel_esp,"retg")
   sel_compra(sel_esp.qual,1)			
  end
	
  --remover carrinho ...............................................................................................+
  if(not sel_car.val and count(ls_car.coisas)>0) then
   sel_car.qual = check_sel(sel_car,ls_car.coisas,"retg")
  end

  if(sel_car.qual != nil and sel_car)then	
   sel_car.qual:hover(sel_car,"retg")
   if(sel_compra(sel_car.qual,2))then
    sel_car.val = false
   end
  end
			
  bt_comp:hover()
  bt_comp:ativa()			
  bt_volt:hover()
  bt_volt:ativa()

 --deposito rocha --------------------------------------------------------------------------------------------------+
 elseif(status == 3)then
  toggle_atl()
  grav_depot()
  --atribuir pra qual atl ..........................................................................................+
  if(not sel_atl.val and ls_atl.show) then
   sel_atl.qual = check_sel(sel_atl,ls_atl.atls,"circ")	 
  end
  
  if(sel_atl.qual != nil)then
   toggle_atribuir(sel_atl.qual)
  end
  
  if(atl_wait) remov_atl()

  --mover coisas ....................................................................................................+
  if(not sel_inv.val and not ls_atl.show) then
   sel_inv.qual = check_sel(sel_inv,ls_inv.coisas,"retg")	 
  end
	
  if(sel_inv.qual != nil)then		
   if(not atribui.val)then
    sel_inv.qual:mov_cur_esq(sel_inv,"retg")	
   elseif(atl_wait)then
	atribuicao()
   end
  end
  
  if(ls_atl.show)then
   bt_dept:hover()
   bt_dept:ativa()
  end
	
 end
end

--draw =============================================================================================================+
function _draw()
 cls()
 --jogo principal --------------------------------------------------------------------------------------------------+
 if(status == 1)then
  bt_skip:des()
  bt_loja:des()
  des_jardim()
  des_atl()
  
  --particulas -----------------------------------------------------------------------------------------------------+
  des_particulas(pat_sem)
	
 --loljinha -------------------------------------------------------------------------------------------------------+
 elseif(status == 2)then
  des_lojinha()
  des_esps(ls_esp[1])
  des_esps(ls_esp[2])
  des_esps(ls_esp[3])
  des_esps(ls_esp[4])
  des_car()
  tool_tip()
  des_bt_comprar()
  bt_volt:des()
 
 --deposito -------------------------------------------------------------------------------------------------------+
 elseif(status == 3)then
  des_depot()
  des_atl()
 end

 mouse:des()
	if(false) then
	 pos_mouse(10)
	 format(cu1,str1)
	 format(cu2,str2)
	 format(cu3,str3)
	 format(cu4,str4)
	 format(cu5,str5)
	 format(cu6,str6)
	 format(cu7,str7)
	 format(cu8,str8)
	 format(cu9,str9)
	 espacamento =0
	end
end

function format(que_cu,str,cor)
 str = str or ""
 cor = cor or 5	
 print(str..tostr(que_cu),0,espacamento,8)
 espacamento+=6	
end

-->8
--classes ==========================================================================================================+
function criar_obj(que_classe,subtipo,ls_guardar,xop,yop)
 novo_obj = {
  --atributos ------------------------------------------------------------------------------------------------------+
  cla      = que_classe,
  s        = 0,
  x				    = xop or 0,
  y 			    = yop or 0,
  w        = 8,
  h        = 8,
  r        = 1,
  n        = 0,
  xoff     = 0,
  yoff     = 0,
  hoff     = 0,
  woff     = 0,
  movable  = false,
  contble  = false,
  sel      = false,
  ct       = 0,
  id       = 0,
  --metodos--------------------------------------------------------------------------------------------------------+
  --mover objeto ..................................................................................................+
  mov = function(self, newx, newy)
   self.x = newx
   self.y = newy
  end,
  --controlar objeto...............................................................................................+]
  cont = function(self,sair_tela,vel)
   if(btn(⬅️)) self.x -= vel
   if(btn(➡️)) self.x += vel
		if(btn(⬆️)) self.y -= vel
	 	if(btn(⬇️)) self.y += vel
	 	
	 	if(sair_tela) n_sai_tela(self) 	
	 end,
	 
	 --desenhar objeto
	 des = function(self,xop,yop)
	 	self.x = xop or self.x
	 	self.y = yop or self.y
	  pal(self.ct,0)
	 	spr(self.s,self.x,self.y,self.w/8,self.h/8)
			pal()
	 end,
	 
	 --mover com o cursor
	 mov_cur = function(self,mouse)
	 	self.x = stat(32) - flr(self.w/2)
	 	self.y = stat(33) - flr(self.w/2)
			n_sai_tela(self)
	 end,
	 
	 //checa colisao entre algo e 
		//o cursor
  col_mouse =	function(self,tipo)
			if(tipo == "retg")then
				//checar entre direita e esquerda, cim e baixo
				esq = self.x+self.xoff
				dir = (self.x+self.xoff)+(self.w-self.woff)
				cim = self.y+self.yoff
				bax = (self.y+self.yoff)+(self.h-self.hoff)
	
				//checar entre direita e esquerda
				if(stat(32)>=esq and  stat(32) <= dir) then
					//checar em cima e embaixo
					if(stat(33)>=cim and stat(33) <= bax) then
						return true	
					end 
	 		end
				
			elseif(tipo == "circ")then
				dx   = self.x - stat(32)
				dy   = self.y - stat(33)
				dist = flr(sqrt((dx*dx)+(dy*dy)))
				if(dist <= (self.r))then
					return true				
				end				
			end
							
			return false
						
		end,
	 
	 //mover objeto com o mouse
	 //esquerdo clicado
	 mov_cur_esq = function(self,controle,tipo)
			//checa colisao do mouse com
			//self
			col = self:col_mouse(tipo)
			//se houve colisao...
			if(col)then
				if(mouse.esq)then
					self.sel     = true
					controle.val = true
				else
					self.sel     = false
					controle.val = false
				end									
			end
			
			//se foi selecionado
			if(self != nil)then
				if(self.sel) then
					self:mov_cur()
				end						
			end
			
	 end
	
	}
	
 def_tip(novo_obj,subtipo,ls_guardar) 

 
 return novo_obj
end

//palavras
function init_palavra(x,y,ls_let)
	 newplv = {
  cla  = "palavra",
	 x    = x,
	 y    = y,
		w    = count(ls_let),
		h    = 4,
	 xoff = 0,
	 yoff = 0,
	 hoff = 0,
	 woff = 0,
		s    = ls_let,
		sel  = false,
		cor1 = 5,
		cor2 = 5,
	 //desenha palavras
	 des = function(self)
			aux = 0
			for i in all(self.s)do
					spr(i,self.x+aux,self.y)
					aux +=5
			end
		end
 }
 
 return newplv
end

--atalho =======================
function init_atl()	
	angulo = 0
	for i=1,4 do
  	new_atl      =	criar_obj("espaco",3)  
 	 new_atl.x    =	new_atl.x - 25 * sin(angulo/360)
 	 new_atl.y    =	new_atl.y - 25 * cos(angulo/360) 	 
 	 new_atl.item = nil
			new_atl.cor1 = 1 	
			new_atl.cor2 = 7
			new_atl.cor3 = 1
			new_atl.id   = i
			new_atl.r    = 8.5
	 	add(ls_atl.atls,new_atl)
	 	angulo+=90
	end
end
-->8
--def_tipos ====================
function def_tip(qual,subtipo,ls_guardar)
	ls_guardar = ls_guardar or nil
--mouse ========================		 
	if(qual.cla == "mouse")then
  qual.ativ      = true
 	qual.s         = 0
		--esperando ==================
 	qual.esq_esper = false
 	qual.mei_esper = false
 	qual.dir_esper = false
		
		--pressionado ================
 	qual.esq_press = false
 	qual.mei_press = false
 	qual.dir_press = false
		
		--estado atual ======================
 	qual.esq = false
 	qual.mei = false
 	qual.dir = false

		--solto ======================
 	qual.esq_solto = false
		qual.mei_solto = false
		qual.dir_solto = false
		
		--estado =====================
		--qual botao?
	function qual:get_estado(qual_mouse)
	 	local estado_atual = stat(34)
			--esquerda ==================
			if(qual_mouse == 1)	then
				return estado_atual==1
			--meio ======================
			elseif(qual_mouse == 4) then
				return estado_atual==4
			--direira ===================
			elseif(qual_mouse == 2)then
				return estado_atual==2
			end
		end
		
	--desenhar mouse ==============
 function qual:des()
  spr(qual.s,stat(32),stat(33))
 end
 
 --atualizar mouse =============
function qual:att()
 	--att posicao ================
 	qual.x = stat(32)
 	qual.y = stat(33)
 	--att posicao ================
		qual.esq=qual:get_estado(1)
		qual.mei=qual:get_estado(4)
		qual.dir=qual:get_estado(2)
		
		--comportamento esquerdo ||||
		--se o mouse esq foi apertado
		if(qual.esq)then
			--se ele estava solto
			if(qual.esq_solto)then
				--agora nao esta mais
				qual.esq_solto=false
			end
			
			--se ele nao estava pressio
			--nado
			if(not qual.esq_press)then
		 	--se nao estava esperando
				if(not qual.esq_esper) then
		 		--agora esta pressionado
		 		--e esperando
					qual.esq_press = true
					qual.esq_esper = true
				end
			--se ja estava pressionado
			else
				--agora no esta mais
				qual.esq_press = false
			end
			
		--se o mouse esq nao foi
		--apertado
		else
		--se estava pressionado
			if (qual.esq_press) then
				--agora nao esta mais
				qual.esq_press=false
			end
			
			--se nao esatava solto
			if(not qual.esq_solto)then
				--se estava esperando
				if(qual.esq_esper)then
					--agora esta solto
					qual.esq_solto = true
					--e nao esta mais esperando
     qual.esq_esper = false
    end
   --se estava solto
   else
   	--agora nao esta mais
   	qual.esq_solto = false
   end
	 end
		
 	--comportamento meio ||||||||
		--se o mouse mei foi apertado
		if(qual.mei)then
			--se ele estava solto
			if(qual.mei)then
				--agora nao esta mais
				qual.mei_solto=false
			end
			
			--se ele nao estava pressio
			--nado
			if(not qual.mei_press)then
		 	--se nao estava esperando
				if(not qual.mei_esper) then
		 		--agora esta pressionado
		 		--e esperando
					qual.mei_press = true
					qual.mei_esper = true
				end
			--se ja estava pressionado
			else
				--agora no esta mais
				qual.mei_press = false
			end
			
		--se o mouse mei nao foi
		--apertado
		else
		--se estava pressionado
			if (qual.mei_press) then
				--agora nao esta mais
				qual.mei_press=false
			end
			
			--se nao esatava solto
			if(not qual.mei_solto)then
				--se estava esperando
				if(qual.mei_esper)then
					--agora esta solto
					qual.mei_solto = true
					--e nao esta mais esperando
     qual.mei_esper = false
    end
   --se estava solto
   else
   	--agora nao esta mais
   	qual.mei_solto = false
   end
	 end
	 
 	--comportamento direita ||||||
		--se o mouse dir foi apertado
		if(qual.dir)then
			--se ele estava solto
			if(qual.dir)then
				--agora nao esta mais
				qual.dir_solto=false
			end
			
			--se ele nao estava pressio
			--nado
			if(not qual.dir_press)then
		 	--se nao estava esperando
				if(not qual.dir_esper) then
		 		--agora esta pressionado
		 		--e esperando
					qual.dir_press = true
					qual.dir_esper = true
				end
			--se ja estava pressionado
			else
				--agora no esta mais
				qual.dir_press = false
			end
			
		--se o mouse dir nao foi
		--apertado
		else
		--se estava pressionado
			if (qual.dir_press) then
				--agora nao esta mais
				qual.dir_press=false
			end
			
			--se nao esatava solto
			if(not qual.dir_solto)then
				--se estava esperando
				if(qual.dir_esper)then
					--agora esta solto
					qual.dir_solto = true
					--e nao esta mais esperando
     qual.dir_esper = false
    end
   --se estava solto
   else
   	--agora nao esta mais
   	qual.dir_solto = false
   end
	 end
	end
--[[
notas
todos os off sao os espao do tile 
nao utilizadoa +1
exemplo:
	se o tile tem 16 de largura
	e ele nao usa 2 colunas na 
	esquerda e direita
	o woff sera 4+1
	o motivo desse +1 e a soma de
	posicao nao considerqar
	o ponto inicial
]]
--teste ========================
	elseif(qual.cla == "teste")then
		qual.s        = 216
  qual.x        = 64
	 qual.y        = 60
	 qual.xoff     = 2
  qual.yoff     = 2
  qual.hoff     = 4
  qual.woff     = 4
  qual.h,qual.w = 16,16
  add(ls_tst,qual)
--particula ====================
	elseif(qual.cla == "particula")then
		qual.vx    = rnd(2) - 1
 	qual.vy    = 1
		qual.x_max = 128
		qual.x_mix = 0
		qual.w     = 0
		qual.h     = 0
		qual.ls    = ls_guardar
		add(ls_guardar,qual)
		
		function qual:att()
			
				qual.x +=	qual.vx
				qual.y += qual.vy 
			//qual.vy += 0.1
				if(qual.x>qual.x_max)then
					qual.x = qual.x_max
					
				elseif(qual.x<qual.x_min)then
					qual.x  = qual.x_min
					qual.vx = -qual.vx
				end
				
				if(saiu(qual))then
 				semear.val = false
					qual:del()
				end
		end
		
		function qual:des()
	  pset(qual.x,qual.y,qual.cor)
	 end
	 
	 function qual:del()
			if(qual)then
		 del(qual.ls, qual)
	  qual = nil
			end
	 end
	
--botao ========================		 
	elseif(qual.cla == "botao")then
		add(ls_bts,qual)
		//lojinha
		if(subtipo == 1)then
 		qual.tip       = 1
			qual.x		       = 1
			qual.y         = 113
	  qual.w,qual.h  = 16,16
	  qual.tam       = 2
	  qual.s,qual.sr = 14,14
		 qual.sp        = 46
		 qual.ct        = 1
		 
	 //voltar
		elseif(subtipo == 2)then
			qual.tip       = 2
			qual.x		       = 1
			qual.y         = 113			
	  qual.w,qual.h  = 16,16
	  qual.tam       = 2
	  qual.s,qual.sr = 12,12
		 qual.sp        = 44
		 qual.ct        = 0

		//comprar
		elseif(subtipo == 3)then
 		qual.tip            = 3
			qual.x	            	= 97
			qual.y              = 116 		
			qual.w              = 18
	  qual.h              = 8
	  qual.cor1,qual.cor3 = 5,5
	  qual.cor2           = 10

	 //depot
		elseif(subtipo == 4)then
 		qual.tip       = 4
			qual.x,qual.y  = 57,57		
			qual.w,qual.h  = 16,16
	  qual.tam       = 2
   qual.s,qual.sr = 40,40
		 qual.sp        = 42
	  qual.ct        = 1
	  
		elseif(subtipo == 5)then
 		qual.tip       = 5
			qual.x,qual.y  = 80,113		
			qual.w,qual.h  = 8,8
	  qual.tam       = 1
   qual.s,qual.sr = 236,236
		 qual.sp        = 237
	 end
	 
	 //metodos de botoes
	 
	 //ativar botao
  function qual:ativa()
			//teve colisao
			if(qual:col_mouse("retg") and not(mouse.eq_press))then
		 //mouse esquerdo pressionado			
				if(mouse.esq_press)then	
					//funcoes ===================
					//ir lojinha
				 if(qual.tip == 1)then
				 	status  = 2		
 	 			mouse.s = 0	
				 
					//voltar jogo principal
				 elseif(qual.tip == 2)then
				 	status = 1
				 
				 
					//comprar
				 elseif(qual.tip == 3)then		
						comprar()				
						 
					//ir depot
					elseif(qual.tip == 4 and not sel_atl.val)then
						if(status==1)then
							status     = 3
							bt_dept.s  = 12
						 bt_dept.sr = 12
						 bt_dept.sp = 44
					  qual.ct    = 0

						elseif(status==3)then
							bt_dept.s  = 40
						 bt_dept.sr = 40
						 bt_dept.sp = 42
							status     = 1
							atribui.val= false
						 qual.ct    = 1

						end					
					 	ls_atl.show = false
						return
					elseif(qual.tip == 5)then
						 avancar_fase()
					end

		 //mouse esquerdo nao pressionado  
				else
					sel_bts.val = false
				end	
			
			//nao teve colisao
			else
					sel_bts.val = false
			end
		
		end
		
		function qual:hover()
			
			if(qual:col_mouse("retg"))then
			
				if(qual.tip == 3 and count(ls_car.coisas)>0)then				
				 qual.cor1 =	qual.cor2
				else
				 qual.cor1 =	qual.cor3
					qual.s    = qual.sp

				end
	
			else
			
			 qual.cor1 =	qual.cor3
				qual.s = qual.sr	
			
			end
		end
	
	elseif(qual.cla == "espaco")then
		qual.w,qual.h = 18,18
 	qual.tam      = 16
 	
 	if(subtipo == 1)then
 	 qual.cor1,qual.cor3 = 1,1
	 	qual.cor2 = 7
			
 	elseif(subtipo == 2)then
			qual.cor1,qual.cor3 = 1,1
	 	qual.cor2 = 8
		
 	elseif(subtipo == 3)then
 		qual.x,qual.y = 64,64
	 	qual.w,qual.h = 16,16
		end

		function qual:hover(qual_sel,tip_col)

			if(qual:col_mouse(tip_col))then
				 qual.cor1 = qual.cor2
			else
				 qual.cor1 = qual.cor3
				 qual_sel.qual = nil
				 qual_sel.val  = false
			end
			
		end
		
	elseif(qual.cla == "prateleira")then			
			qual.h = 1
			qual.w = 80

	elseif(qual.cla == "item")then				
		qual.w  = 16
		qual.h  = 16
		//pa
		if(subtipo == 1)then
 		qual.tip  = 1
		 qual.val  = 200
		 qual.nome = "shovel"
		 qual.s    = 2
		 qual.xoff = 2
			qual.yoff = 2
 	 qual.woff = 5
 		qual.hoff = 5

		//regador
	 elseif(subtipo == 2)then
 		qual.tip  = 2
		 qual.val  = 300
		 qual.nome = "watering can"
		 qual.s    = 4
		 qual.xoff = 1
			qual.yoff = 6
 	 qual.woff = 3
	 	qual.hoff = 9
	  qual.ct   = 1
	  
		//borrifador
	 elseif(subtipo == 3)then
 		qual.tip  = 3
	  qual.val  = 400
		 qual.nome = "pesticide"
		 qual.s    = 6
		 qual.xoff = 3
			qual.yoff = 1
 	 qual.woff = 7
	 	qual.hoff = 4
	 	
		//fertilizante	 	
	 elseif(subtipo == 4)then
 	 qual.tip  = 4
	  qual.val  = 500
		 qual.nome = "fertilizer"
		 qual.s    = 8
		 qual.xoff = 3
			qual.yoff = 1
 	 qual.woff = 7
	 	qual.hoff = 4
	 	
	 //vasos rocha
	 elseif(subtipo >= 5 and subtipo <= 8 )then
	 	qual.estagio = 1

  	function qual:des_planta()
  		local aux = qual.planta.wh[qual.estagio][1]
  		if(aux > 1)then
  		 spr(qual.planta[qual.estagio],qual.x          ,qual.yp-(qual.planta.wh[qual.estagio][2]*8),qual.planta.wh[qual.estagio][1],qual.planta.wh[qual.estagio][2])
  		else
  		 spr(qual.planta[qual.estagio],qual.x+qual.xesp,qual.yp-(qual.planta.wh[qual.estagio][2]*8),qual.planta.wh[qual.estagio][1],qual.planta.wh[qual.estagio][2])
  		end
  
  	end
  	
  	function qual:des(xop,yop)
  		qual.x = xop or qual.x
		 	qual.y = yop or qual.y
		 	//cordenadas onde planat fica no vaso		 	
		 	qual.xp = qual.x+qual.xpoff
		 	qual.yp = qual.y+qual.ypoff

		  pal(qual.ct,0)
		 	spr(qual.s,qual.x,qual.y,qual.w/8,qual.h/8)
				pal()
				
				if(qual.planta)then
					qual:des_planta()
				end			
  	end
			
			//vaso1
		 if(subtipo == 5)then
	 	 qual.tip  = 5
			 qual.val  = 500
			 qual.nome = "flowerpot 1"
			 qual.s    = 32
			 qual.xoff = 2
				qual.yoff = 5
	 	 qual.woff = 5
		 	qual.hoff = 8
		  qual.ct   = 1

		  //cordenadas da plnat no vaso

		  qual.xpoff = 8 
		  qual.xesp  = 4
		  qual.ypoff = 8
		
			//vaso2
		 elseif(subtipo == 6)then
		  qual.tip  = 6
			 qual.val  = 500
			 qual.nome = "flowerpot 2"
			 qual.s    = 34
			 qual.xoff = 2
				qual.yoff = 5
	 	 qual.woff = 5
		 	qual.hoff = 7
		  qual.ct   = 1
		 
		  qual.xpoff = 8
		  qual.xesp  = 4
		  qual.ypoff = 7
		 			 
			//vaso3
		 elseif(subtipo == 7)then
		  qual.tip  = 7
			 qual.val  = 600
			 qual.nome = "flowerpot 3"
			 qual.s    = 36	
			 qual.xoff = 3
				qual.yoff = 2
	 	 qual.woff = 7
		 	qual.hoff = 5
		  qual.ct   = 2
		 	
		  qual.xpoff = 8
		  qual.xesp  = 4
		  qual.ypoff = 5
		 		
			//vaso4
		 elseif(subtipo == 8)then
		  qual.tip  = 8
			 qual.val  = 600
			 qual.nome = "flowerpot 4"
			 qual.s    = 38
			 qual.xoff = 1
				qual.yoff = 2
	 	 qual.woff = 3
		 	qual.hoff = 5
		  qual.ct   = 2
		 
		  qual.xpoff = 8
		  qual.xesp  = 4
		  qual.ypoff = 5
		  
	 	end	
		//planta1
	 elseif(subtipo >= 9 and subtipo <= 16 )then
		 qual.s    = 10
		 qual.ct   = 1
		 qual.xoff = 2
			qual.yoff = 2
 	 qual.woff = 5
	 	qual.hoff = 5
	 	
		 if(subtipo == 9)then
		  qual.tip  = 9
			 qual.val  = 400
			 qual.nome = "tomato"
		 	qual.fases= {70   ,71   ,87   ,85   ,72   ,104 ,
           wh = {{1,1},{1,1},{1,2},{2,2},{2,2},{2,2}} }
		 		 
			//planta2
		 elseif(subtipo == 10)then
		  qual.tip  = 10
		  qual.val  = 500
			 qual.nome = "bear_pawn"		
		 	qual.fases= {64   ,65   ,66   ,67   ,68   ,74  , 76  ,
           wh = {{1,1},{1,1},{1,1},{1,1},{2,1},{2,2},{2,2}} }		 					 
			  	
			//planta3
		 elseif(subtipo == 11)then
		  qual.tip  = 11
		  qual.val  = 600
			 qual.nome = "pumpkin"
		 	qual.fases= {96   ,97   ,114  ,115  ,117  ,168  ,136  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,1},{2,2},{2,2}} }		 					 
			  				 		 	
		 //planta4
		 elseif(subtipo == 12)then
		  qual.tip  = 12
		  qual.val  = 1000
			 qual.nome = "pegaxi"		
 	 	qual.fases= {96   ,97   ,114  ,115  ,117  ,106  ,108  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,1},{2,2},{2,2}}} 					 
  				 		 			  	
		 //planta5
		 elseif(subtipo == 13)then
		  qual.tip  = 13
		  qual.val  = 500
			 qual.nome = "sunflower"
			 qual.fases= {96   ,80   ,81   ,82   ,83   ,84   ,
           wh = {{1,1},{1,1},{1,1},{1,2},{1,2},{1,2}}} 					 	 	
		
		 //planta6
		 elseif(subtipo == 14)then
		  qual.tip  = 14
		  qual.val  = 350
			 qual.nome = "sword"		 	
			 qual.fases= {64   ,112  ,113   ,130 ,132  ,134  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,2},{2,2}}} 					 	 	
		 //planta7
		 elseif(subtipo == 15)then
		  qual.tip  = 15
		  qual.val  = 600
			 qual.nome = "rose"
			 qual.fases= {70   ,176  ,177  ,162  ,163  ,164  ,165  ,
           wh = {{1,1},{1,1},{1,1},{1,2},{1,2},{1,2},{1,2}}} 			 

		 //planta8
		 elseif(subtipo == 16)then
		  qual.tip  = 16
		  qual.val  = 1000
			 qual.nome = "dandelion"
			 qual.fases= {70   ,128  ,129  ,146  ,138  ,140  ,
           wh = {{1,1},{1,1},{1,1},{1,2},{2,2},{2,2}}} 			 

		 end 
		end
	end

end

-->8
--colisor e utilitrios =========
//nao deixa um objeto sair
//da tela
function n_sai_tela(oque)
	if(oque != nil)then
		esq = oque.x+oque.xoff
		cim = oque.y+oque.yoff
		dir = esq+oque.w-oque.woff
		bax = cim+oque.h-oque.hoff
		if(esq <  0) oque.x = -oque.xoff
		if(cim <  0) oque.y = -oque.yoff
 	if(dir >127) oque.x = oque.x+(127-dir)
 	if(bax >127) oque.y = oque.y+(127-bax)-1
	end
end

--saiu da tela
function saiu(oque)
	if(oque != nil)then
		esq = oque.x+oque.xoff
		cim = oque.y+oque.yoff
		dir = esq+oque.w-oque.woff
		bax = cim+oque.h-oque.hoff
		if(esq <  0) return true
		if(cim <  0) return true
 	if(dir >127) return true
 	if(bax >127) return true
 	return false
	end
end

//checa colisao entre dois retangulos
function col_2ret(q1,q2)
	esq_1 = q1.x+q1.xoff
	cim_1 = q1.y+q1.yoff
	dir_1 = esq_1+q1.w-q1.woff
	bax_1 = cim_1+q1.h-q1.hoff
	
	esq_2 = q2.x+q2.xoff
	cim_2 = q2.y+q2.yoff
	dir_2 = esq_2+q2.w-q2.woff
	bax_2 = cim_2+q2.h-q2.hoff

	//checar entre direita e esquerda
	if(esq_1 < dir_2 and dir_1 > esq_2)then
  if(cim_1 < bax_2 and bax_1 > cim_2)then
			return true
		end
	end

	return false	
	
end


//colisao de dois circulos
function col_circ(q1,q2)
	dx   = q1.x - q2.x
	dy   = q1.y - q2.y
	dist = sqrt((dx*dx)+(dy*dy))
	if(dist <= (q1.r+q2.r))then
		return true
	end
	
	return false
	
end

//colisa de um circulo e 1 ponto
function col_circ_pt(cic,pt)
	dx   = cic.x - pt.x
	dy   = cic.y - pt.y
	dist = flr(sqrt((dx*dx)+(dy*dy)))
	if(dist <= (cic.r))then
		return true
	end
	
	return false
	
end

--mover objeto com o mouse
function mover_obj_mos(qual,controle,tipo)
	local col = false
	if(tipo == "retg")then
		col = check_col_point_ret(qual.x,qual.y,qual.h,qual.w,stat(32),stat(33))
	elseif(tipo == "circ")then
		col=col_circ_pt(qual,mouse)
	end
	
	if(col)then
		if(mouse_esq())then
			qual.sel = true
			controle.val = true
		else
			qual.sel = false
			controle.val = false
		end									
	end
	
	if(qual != nil)then
		if(qual.sel) then
				qual.x = stat(32)-flr((qual.w/2))
				qual.y = stat(33)-flr((qual.h/2))
				n_sai_tela(qual)
		end						
	end
	
end

//retorna o obejto selecionado
//em uma lista
function get_obj_by_col_mos(lista,tipo)
	
	for qual in all(lista)do
		col= qual:col_mouse(tipo)
		if(col)return qual
	end	
	return nil
end

function get_obj_by_col_retg(ls_oque_1,oque_2)
	
	for qual in all(ls_oque_1)do
		col = col_2ret(qual,oque_2)		if(col)return qual
		if(col)return qual
	end	
	return nil
end

//checa a selecao de objetos
//em uma lista
function check_sel(que_sel,qual_ls,tipo)
	if(count(qual_ls))then
			obj_sel = get_obj_by_col_mos(qual_ls,tipo)					
			if(obj_sel != nil)then
				que_sel.val = true
				return obj_sel
			else
				que_sel.val = false
				return obj_sel
	 	end
		
	else
		return nil
	end

end

//desenhar vertice
function des_vertices(x,y,w,h,cor)

 pset(x    ,y    ,cor)
 pset(x+w-1,y    ,cor)
 pset(x    ,y+h-1,cor)
 pset(x+w-1,y+h-1,cor)

end

//retorna as chaves de uma tabela
function get_keys(qual_ls)
	keys = {}
	for i,j in pairs(qual_ls)do
		add(keys,i)
	end
	return keys
end

//exibe x y do mouse
function pos_mouse(cor)
		print("("..stat(32)..","..stat(33)..")",100,120,cor)
end

//apaga uma lista
function del_ls(qual_ls)
	for i in all(qual_ls)do
		del(qual_ls,i)
	end
end

//particulas
function des_particulas(que_ls)

 for p in all(que_ls) do
 	p:des()
 end

end

//atualizar prticulas

function att_particulas(que_ls)

 for p in all(que_ls) do
 	p:att()
 end

end

function gerar_part(que_pat, cor, ampx)
	nova = criar_obj("particula",0,que_pat)
	nova.x     = stat(32)
	nova.y     = stat(33)
	nova.item  = do_que
	nova.cor   = cor
	nova.x_max = nova.x+ampx
	nova.x_min = nova.x-ampx
	return nova 
end

function avancar_fase()
	if(status==1 and not ls_atl.show)then
		for i in all(ls_vas_atv)do
			local inc = flr(rnd(100))
			i.estagio+= inc%2
			if(i.estagio>#i.planta)i.estagio=1		 
		end
	end
end

-->8
--loljinha =====================
function	des_lojinha()
 //base
	rect(8,2,119,114,5)
	line(92,114,118,114,0)
	//compartimentos			
	rect(37,7,91,28,5)
	rect(32,35,91,55,5)
	rect(42,63,91,83,5)
	rect(47,91,91,114,5)
	
	//linhas do lado labels
	rect(35,30,91,32,5)
	rect(35,31,90,32,0)
	
	rect(45,58,91,60,5)
	rect(45,59,90,60,0)

	rect(50,86,91,88,5)
	rect(50,87,90,88,0)
 
 //tools
 rect(8,2,37,28,5)
 rectfill(9,3,36,27,0)
 rectfill(8,28,91,29,0)
 
 //pots
	local addy = 28
 rect(8,2+addy,32,28+addy,5)
 rectfill(9,36,90,55,0)
 rectfill(8,56,91,57,0)
 
 //plants
 addy +=28
 rect(8,2+addy,42,28+addy,5)
 rectfill(9,64,90,83,0)
 rectfill(8,84,91,85,0)
 
 //flowers
 addy +=28
 rect(8,2+addy,47,28+addy,5)
 rectfill(9,92,90,113,0)
	rectfill(9,112,90,113,0)
	
	//do lado dos labels			
	rect(38,2,39,6,0)
	line(37,8,37,9,0)
	line(32,36,32,37,0)
	line(42,64,42,65,0)
	line(47,92,47,93,0)
	
	//botao de comprar
	rect(92,114,119,126,5)
	rectfill(92,114,118,125,0)
	des_vertices(95,115,22,10,5)
	
	//carrinho de compra
	local y=0
	for i=1,4 do
		rect(95,7+y,116,28+y,5)
		des_vertices(98,10+y,16,16,5)
		y+=28
	end
	
	//precos
 rect(14,117,91,126,5)
 rectfill(15,118,90,125,0)
 rect(14,117,66,126,5)
 
 tools:des()
	pots:des()
 plants:des()
 flowers:des()
 
end

//cria vitrines
function criar_esps(quantos)
	linha ={}

	for i=1,quantos do      
  aux      = criar_obj("espaco",1)
		aux.item = criar_obj("item"  ,aux_tipo)
		add(linha,aux)
		aux_tipo+=1		

	end	
		add(ls_esp,linha)

end

//enfileira as vitrines
function enfileirar_esp(qual,ondex,ondey)

	for i in all(qual)do
		i.x = ondex
		i.item.x = i.x+1
		i.y = ondey
		i.item.y = i.y+1
		ondex += 20
	end	

end

//desenha todas as vitrines
function des_esps(qual_linha)

	for i in all(qual_linha)do
		des_esp(i)
	end

end

//desenha uma vitrine
function des_esp(i)

	rect(i.x,i.y,i.x+i.w-1,i.y+i.h-1,i.cor1)	
	rectfill(i.x+1,i.y+1,(i.x+i.w-1)-1,(i.y+i.h-1)-1,0)	
 i.item:des(i.x+1,i.y+1)
 des_vertices(i.x+1,i.y+1,i.w-2,i.h-2,i.cor1)

end

//seleciona produto
//e envia para o carrinho rocha
function sel_compra(qual,op)
	if(qual == nil) return
	if(qual:col_mouse("retg") and not(mouse.eq))then
 
		if(mouse.esq_press)then
				//adiciona ao carrinho
				if(op==1)then
					if(count(ls_car.coisas)<4)then
				  new_car      = criar_obj("espaco",2)
						new_car.item = criar_obj("item",qual.item.tip)
						ls_car.total += qual.item.val
					 add(ls_car.coisas,new_car)
					 return true
					end
				//remove do carrinho
				elseif(op==2)then
					if(count(ls_car.coisas)<=4)then
	 				ls_car.total -= qual.item.val
					 del(ls_car.coisas,qual)
					 return true
					end					
				end
		end		
	end	
	return false
end

//desenha o carrinho de compras
function des_car()

	if(count(ls_car.coisas)>0)then
		 
		for i=1,count(ls_car.coisas) do
		 ls_car.coisas[i].x=97
			if(i==1)then
				ls_car.coisas[i].y=9
			end
			if(i==2)then
				ls_car.coisas[i].y=37
			end
			if(i==3)then
				ls_car.coisas[i].y=65
			end
			if(i==4)then
				ls_car.coisas[i].y=93
			end
			des_esp(ls_car.coisas[i])
		end
		
	end
	
end

function des_bt_comprar()
	rect(bt_comp.x,bt_comp.y,bt_comp.x+bt_comp.w-1,bt_comp.y+bt_comp.h-1,bt_comp.cor1)	
	if(not bt_comp:col_mouse("retg"))then
			buy:des()
	else
		if(count(ls_car.coisas)>0)then
		 buy_atv:des()
		else
			buy:des()
		end
	end
end

function tool_tip()
	//mostrar preco ao passar mouse
	if(sel_esp.val)then
		if(sel_esp.qual != nil)then
			auxtip = sel_esp.qual.item.tip
			if(auxtip >=9 and auxtip <=16)then
				print("seeds",17,120,6)			
			else
				print(sel_esp.qual.item.nome,17,120,6)
			end
			
	  print(sel_esp.qual.item.val,69,120)
		end
	
	elseif(bt_comp:col_mouse("retg") and ls_car.total!=0 )then
			print("total",17,120,10)
	  print(ls_car.total,69,120,10)
	
	//mostrar preco ao passar mouse no carrinho
	elseif(sel_car.val)then
	
		if(sel_car.qual != nil)then			
			print(sel_car.qual.item.nome,17,120,6)
	  print(sel_car.qual.item.val,69,120,6)
 	end

	//mostrar saldo 	
	else
		print("money",17,120,13)
		print(saldo,69,120,13)
	end
end

function comprar()
	if(ls_car.total<=saldo)then
		saldo -= ls_car.total	
		ls_car.total	= 0
		
  add_varios_itens(ls_car.coisas,2)
  del_ls(ls_car.coisas)
		return true
	end
	
	return false
	
end
-->8
--inventario ===================
function des_inv()
	if(status==3)then
		for k in all(ls_inv.coisas)do
				k:des()
		end
	else
 	for k in all(ls_jrd.coisas)do
				k:des()
		end
	end
end

function espalhar_pos(ls_doque)

	for i in all(ls_doque)do
		i.x = rnd(112)
	 i.y = rnd(112)
	 n_sai_tela(i)
	end

end

function add_um_item(qual,onde)
	
	if(status == 2)def_pos(qual)
	if(onde == 1)    	add(ls_jrd.coisas,qual)
 if(onde == 2)	add(ls_inv.coisas,qual)
 
end

function add_varios_itens(qual_ls,onde)
	
	for i in all(qual_ls)do
		add_um_item(i.item,onde)
	end

end

function print_inv()
	yplus = 1
	if(count(ls_inv.coisas)>0) then
	 yplus += 6
	 for i in all(ls_inv.coisas)do
 	 print(i.nome,1,yplus,15)
 	 yplus += 6
	 end
	end
end
-->8
--menu_de_atalho=================
function des_atl()

	if(ls_atl.show)then
		for i in all(ls_atl.atls)do
   ovalfill(i.x-8, i.y-8,i.x+9,i.y+9,0)
   oval(i.x-8, i.y-8,i.x+9,i.y+9,i.cor1)

			if(i.item !=nil)then
			 i.item:des(i.x-7,i.y-7)
			end
 			i:hover(sel_atl,"circ")
		end  	
  bt_dept:des()
	end

end

function cool_down(tempo)

	if atribui.val then
		timer_atl +=1
		if(timer_atl>tempo)then
   atl_wait = true  
		 return true
		end
	else
  atl_wait = false
	 return false
	end
	

end

//mostrar-ocultar atalhos
function toggle_atl()

	if(mouse.dir_press)then
			if(ls_atl.show)then 
				ls_atl.show = false		
			else
 			mouse.s = 0
				ls_atl.show = true
				atribui.val = false
				semear.val  = false
				atribui.atl = nil
				sel_inv.val = false
			end
	end
		
end


function toggle_atribuir(qual)

	if(mouse.esq_press)then	
  	qual.cor1   = qual.cor3
			ls_atl.show = false
			atribui.val = true
			atribui.atl = qual
			
			if(qual.item != nil and status == 1)then
   		if(qual.item.tip == 1) mouse.s = 16
   		if(qual.item.tip == 3) mouse.s = 17
   		if(qual.item.tip >= 9) mouse.s = 1
			end
	end
								
end

function atribuicao()

 vaso_com_planta = sel_jrd.qual and sel_jrd.qual.tip >= 5 and sel_jrd.qual.tip <= 8 and sel_jrd.qual.planta

	if(mouse.esq_press and not vaso_com_planta)then
		//deleta o item selecionado
		//e salva
		if(status == 3) then
			aux_item = del(ls_inv.coisas,sel_inv.qual)		
		elseif(status == 1) then
			aux_item = del(ls_jrd.coisas,sel_jrd.qual)	
		end
					
		//se o atalho estiver vazio
		//simplesmente poe nele
		//caso nao, os item que
		//tava no atalho volta pro inv
		if(atribui.atl.item != nil)then
 		atribui.atl.item.x = aux_item.x
 		atribui.atl.item.y = aux_item.y-8
			if(status == 3) then
				add(ls_inv.coisas,atribui.atl.item)
			elseif(status == 1) then
		 	funcionalidades(atribui.atl.item)
			end
		end
		
		atribui.atl.item = aux_item
		atribui.val  = false
		sel_inv.qual = nil
		sel_inv.val  = false		
		sel_jrd.qual = nil
		sel_jrd.val  = false
		ls_atl.show  = true

	else
		sel_inv.val = false
		sel_jrd.val = false
	end	
	
end

function remov_atl()
	
	if(atribui.val and atribui.atl.item != nil and sel_inv.qual == nil and not(bt_loja:col_mouse("retg")))then
		if(mouse.esq_press) then
			atribui.atl.item.x=stat(32)-8			
			atribui.atl.item.y=stat(33)-8
			if(status == 3) then
				add(ls_inv.coisas,atribui.atl.item)
			elseif(status == 1) then
		 	funcionalidades(atribui.atl.item)
			end
			
			atribui.atl.item = nil
			atribui.val      = false
			sel_atl.qual     = nil
			sel_inv.qual     = nil
			sel_inv.val      = false
			sel_jrd.qual     = nil
			sel_jrd.val      = false			
		end
	end
end
-->8
--deposito======================
function des_depot()
 //base
	rect(107,3,119,115,1)
	rect(8,3,107,115,4)
	//pesinhos
	rect(16,118,28,122,1)
	rect(8,118,16,122,4)
	rect(107,118,119,122,1)
	rect(99,118,107,122,4)
	line(8,118,119,118,0)
	des_prateleiras(16,20,24)
	des_inv()
end

function des_prateleiras(x_init,y_init,y_esp) 

	aux_y = y_esp
	for i in all(ls_prt)do
		i.x  = x_init
	 i.y  = aux_y
  rect(i.x,i.y,i.x+i.w-1,i.y+i.h-1,5)
		aux_y += y_esp
	end
	
end

function criar_prateleiras(quantas)
	for i=0, quantas do
		aux_prt = criar_obj("prateleira",0)
		add(ls_prt,aux_prt)
	end	
end

function grav_depot()

	for i in all(ls_inv.coisas) do
		it={
			x = i.x+i.xoff,
			y = i.y+14,
			h = 1,
			w = i.woff,
			xoff = 0,
			yoff = 0,
			woff = 0,
			hoff = 0,	
		}		
		if(
			not	col_2ret(it,ls_prt[1])and
			not	col_2ret(it,ls_prt[2])and
			not	col_2ret(it,ls_prt[3])and
			not	col_2ret(it,ls_prt[4])
		)then
			i.y+=grav
			n_sai_tela(i)	
  else
			i.y = flr(i.y)
		end	
	end

end

function def_pos(i)
		i.x = flr(rnd(80)) + 16 

		if(i.tip <=4)then
			i.y = 10
		elseif(i.tip<=8)then
			i.y = 34
		else
			i.y = 58
		end

end
-->8
--jardim =======================
function des_jardim()
 des_inv()
end

function funcionalidades(que_item)
	que_item = que_item or nil	

	if(que_item.tip >= 5 and que_item.tip <=8)then
		add(ls_jrd.coisas,que_item)
	else		
  nova_sem      = gerar_part(pat_sem,3,2)
	 nova_sem.item = que_item
		semear.val    = true
		semear.qual   = nova_sem
	end
	
	
	
end

function plantar(o_que)
	
	qual_vaso = get_obj_by_col_retg(ls_jrd.coisas,o_que)

	if(qual_vaso)then
		add(ls_vas_atv,qual_vaso)
		qual_vaso.planta  = o_que.item.fases
 	qual_vaso.estagio = 1
  o_que:del()
 	semear.val = false
 	mouse.s = 0
 end
end


__gfx__
00000000011111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770167776110000000000000000000000000000000000005577777000000000004224000000000000000000000000000000000000000000000000000000
06111700777777770000000005dddd00000000000000000000005566666000000000049119400000000066666660000000000000000000000550000000000000
06117000677677760000000056677d000000000000000000000000d666d00000000002499420e000000611111116600000000000000000000555555555555500
0616160067611766000000056dd67d0000000000000000000000055ddd00000000000022220e0000006111111161150000000500000000000051111111111500
066066707617661100000000d56d6d0000000000000000000000560dd0000000000000eeee2ee00000f1111111f1150000005555555000000051551551551500
060007701717110000000000055d6500006500066666070000006060060000000000044444400000000fffffff11150000055555555500000051111111111500
000000000111000000000000d0d65000065700665557607000000700006000000000e444111e000000d1111111d1150000005555555500000051155155115000
0ddd00000dddd0000000000d000500000575007611177060000007bbbb60000000044ee13314400000d1bb1bb1d1150000000500001500000051111111115000
d776d000057650000000006000000000000560577777506000007333333d00000002441bb314200000611bbb1161150000000000011100000055555555550000
d7dd6d00576dd50000442600000000000000565555555050000733b33b33d00000024413b1442000006111311161150000001111111000000050000000000000
56d7d50055d7bdd00020020000000000000005556756550000063333bbb3d0000002213114422000006111311161150000001111110000000055555555555000
056d7000005b7bbd00020400000000000000005567565000000063333b3d00000000211222220000006111111161150000000000000000000005500005500000
005506440053bbbd00002400000000000000000566560000000006666dd00000000002222220000000066666666dd00000000000000000000005500005500000
00000204000533350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000422000555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000444466444400000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111110000000000000000000770000000000000
0000000000000000000000000000000000000dddddd00000000dddddddddd0000004444664444000009999977999990000000000000000000777777777777700
000000000000000000000000000000000000d122221d000000d1111111111d000044444664444400001111177111110000000700000000000071111111111700
00000000000000000002444444442000000061222216000000d1122222211d000044444664444400001111111111110000007777777000000071771771771700
00224444444422000021111111111200000016666661000000612222222216000044444664444400001122222222110000077777777700000071111111111700
00211111111112000041414121411400000001111110000000166666666661000011111661111100001122222222110000007777777700000071177177117000
0041414121411400004112141214140000000d1111d00000000d11111111d0000041416666141400009191777719190000000700005700000071111111117000
00411214121414000091214141411900000066dddddd00000066dddddddddd000041416116141400009191711719190000000000055500000077777777770000
00912141414119000009999999999000000d66dddd6dd0000d66d6dd6ddd6dd00041441661441400009199177199190000005555555000000070000000000000
009999999999990000011111111110000001ddddd666100001ddddddd6d666100041444444441400009199999999190000005555550000000077777777777000
0002111111112000000024422222000000011ddddd6110000111dd6ddddd61100041444444441400009199999999190000000000000000000007700007700000
00022444422220000000244222220000000011111111000000111666111111000041111111111400009111111111190000000000000000000007700007700000
0002244442222000000004422220000000000111111000000001116111d110000044444444444400009999999999990000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000b03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0bbb30b000000000000000000b0b000000000000000000000000000000000000000000000000000000000000000000
000000000000000000bb30000bbb300000bbbbb30b330b000000000000003000000000000bb00000000000000000000000000000000000000000000000000000
00000000000b300003bbb100bbbbb10000bbbbbbbbb330000000000000b0bb000000bb00b000000000000000000000000000000000000000000000b033000000
0000000000bbb3000bbbb100bbbbb13000bbbbbb3b3330000bb0bb00000b00000000030300bb0000000000000000000000000000000000000000000b30000000
0000b00000bb33000bbb3100bbbb3133003bbbb33333300000b330000b33bb00000bb03a0bb000000003300000000000000a9000000000000000003bb3000000
000b330000b3310003b331003bb331330003bb3313330000000300000003300000000a00300bb00000033300000000000009a300000000000000031331300000
000111000001100000331000033310000000333100000000001111000011110000000000b300000000000b000000000000000b00000000000000b131331b0000
0000000000003000000000000000000000000000000000000000000000000000000b300b30a00000003030b0b4000000009040b049000000000031b1bb130000
000000000003b0000000000000000000000000000000000000000000000000000000033b00000000030bbb304b3304b00a0bbb30943304900033313133133300
00000000003b310000000000000000000000a0000000000000000000000000000000b00b000bb00000bbb3b333333b4000bbb3b3133339400003113133113000
003003000013110000000000000000000a9aa9a0000000000bb0000000000000000b0a0333b000000bbbbb33bbb333000bbbbb33bbb1130000bbb111311bbb00
0003300000011000000000000000b00009a24a900000bb00b0000000000000000000000330bb00000b3bbbb13b3333000b3bbbb13b311300000bb31bb13bb000
00bb100000b31300000000000b3bb3b0aa2424a00000030300bb000000000000000000033000000003b3bb311333310003b3bb31133331000000113bb3330000
00013300000110000000000003b2ab300a4242aa000bb0330bb0000000b00b000000000330000000003bb33103331000003bb3310333100000000113b1100000
0031100000311300000bb000bb242ab009a42a9000000000300bb0000bb0b0000000001111000000000333100000000000033310000000000000000000000000
000000000000000000b33b000ba242bb0a9aa9a000000000b3000000000030000000000000000000000000000000000000000000000000000000000000000000
00000000000000000b3423b003ba2b300001a000000b300b3000000000b0b3000000000000000000000000000000000000000000000000000000000000000000
00000000000000000b3243b00b3bb3b000b313300000033b00000000b00b30b0000000000bb00000000000000000000000000000000000000000000000000000
000000000000000000b33b000001b1000bbb13000000b00b000bb0000b3b00000000bb00b00000000000000000000000000003b30b30000000000000b0000000
0000000003000030000bb00000b31bb000033bb0000b000333b00000000b00b00000030300bb0000000000b0330000000000303bb303000000000b3bb3b00000
00b11300033103300bb31bb00bbb3bbb00031bbb0000000330bb000000033b00000bb0382bb000000000000b3000000000000003b0000000000003bddb300000
003b33000b111b300031110000311100003111000000000330000000000330b000008202800bb0000000003bb300000000000cc33cc000000000bb0d90b00000
0001100000b3b30003131330031313300313133000000011110000000011110000002800b382000000000333333000000000c7cccc7c000000000b4009bb0000
0000000000000000000000000000000000000000000000133300000000000000000b300b302800000000b333333b00000000cc7777cc0000000003b49b300000
000000000000000000000000000000000000000000000b3133b30000000000000000033b0000000000303b3333b303000300dccccccd003000000b3bb3b00000
0000000000033000000000000003301331033000000331bbbb133000000000000000b82b000bb000003313bbbb31330000331dddddd1330000000001b1000000
0000000000300300300110030000113333110000000011313311000000000000000b028b33b000000003113333113000000311dddd113000000000b31bb00000
00000000b0b00b0b13133131000bb111111bb000000bb111111bb000000000000000000330bb000000bbb111111bbb0000bbb112211bbb0000000bbb3bbb0000
00bb3000b00bb00bb111111b0000b31bb13b00000000b31bb13b0000000000000000000330000000000bb31bb13bb0000b0bb31bb13bb0b00000003111000000
00b00300033333303b1bb1b30000113bb33300000000113bb33300000000000000000003300000000000113bb33300000000113bb33300000000031313300000
0031130000311300013bb31000000113b110000000000113b110000000000000000000111100000000000113b110000000000113b11000000000000000000000
0000000000000000000000bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000
00000000000b3300000000b00b0bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000090aa00000000
0000000000b03300000bb0300330b0000000000000000000000000b000000000000000000000000000000000000000000000000000000000000099aa99900000
000000000b300000000b030bb030b0000000000000000000000000bb000000000000b0000bbb00000000000000000000000000000000000000009adda9000000
0bb030000033b000000b03b00b0030000000000000000000000000b0b0000000000b0bb033b000000000000000000000000000300000000000aa0ddd0aa00000
000b0000000b00000000303003030000000000bbb0000000000000b00b00b0000000000b3000000000000000000000000000000b30000000000a90009aaa0000
0000b0000000b0000000030000300000000000b00b000000000b0030030bb0000000003bb30000000000000000000000000000b000f0f0000000a909a9000000
00031130000311300000311111130000000000b00b0bb000000bb0100030b0000000092332900000000000b003bb000000000b000f0f0f00000999aa99000000
00000000000000000000000300000000000bb0300330b000000b0310b030b0000000a292992a000000000b00333bb00000000300f07070f00000001a190bb000
0000000000000000000000b09a000000000b03000030b000000b030b0b303000000092a2aa29000000000300b3b3b300000bb3000f070f00000bb00110bb3300
000000000000000000000b09a9a00000000b030bbb303000000b030b0b3030000033929299293300000bb300bb300300000033006060606000bbbb3013330030
00000000000000000000030a9a900000000b03b00b003000000300b00b003000000322929922300000003bb00bb0300000000bb00606060000003bb313000000
0000000000000000000bb300a90000000003003003003000000300300300300000bbb222922bbb0000000b000033000000000b00006060000000000310000000
000000000000000000000bb00000000000003030030300000000303003030000000bb32bb23bb000000030b000000000000030b0000000000000003111000000
00000000000000000000000b00000000000003000030000000000300003000000000113bb33300000000000b000000000000000b000000000000031313300000
000000000000000000000311113000000000311111130000000031111113000000000113b1100000000003111130000000000311113000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb00b300000
0000000000000000000000000000000000000000000888000000000000000000000000000000000000003330000000000000b0000bbb00000000bbbb03330000
000000000000000000000000000000000000000088800080000000000000000000000000000000000000033000000000000b0bb033b000000000000b30000000
00000000000000000000000000000000000d000080088080000000000000000000000033033000000000000b300000000000000b300000000000088338800000
0000000000000000000000000003000000d0d0000800080000000000000000000000000b30000000000000b000a0a0000000003bb30000000000878888780000
000000000000000000000000003030000b404b000b888b0000000000000000000000003bb300000000b00b000a0a0a0000000a9339a000000000887777880000
0000000000000000000300000bb0bb0000bb300000bb30000000000000000000000003133130000000bb0300a07070a0000079a9aa9700000030288888820300
00000000000000000bb0bb0000bb3000000300000003000000000000000000000000b131331b0000000bb3000a070a000000a979779a00000033122222213300
000000000bb0bb0000bb3000000300000bb300000bb300000000000000000000000031b1bb13000000003300909090900033a9a9aa9a330000b3112222113b00
0000000000bb3000000300000bb30000b0033300b00333000000000000000000003331313313330000000bb009090900000399a9aa99300000bbb11b111bbb00
0bb0bb00000300000bb30000b003330000330030003300300000000000000000000311313311300000000bb00090900000bbb999a99bbb00000bb31bb13bb000
00b3300000b3000000033300003300300003b0000003b000000000000000000000bbb111311bbb00003330b000000000000bb39bb93bb0000000113bb3330000
0003000000033000003300000003b00000330b0000330b000000000000000000000bb31bb13bb0000003300b000000000000113bb33300000000011111100000
00030000000300000003000000330000000300000003000000000000000000000000113bb3330000000003333330000000000113b11000000000000000000000
001111000011110000111100001111000011110000111100000000000000000000000113b1100000000000000000000000000000000000000000000000000000
55550000555500005500000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05500000550500005500000055050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05500000550500005500000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100888888000
05500000555500005555000055050000000000000000000000000000000000000000000000000000000000000000000000000000000000000010010888888000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010010000088000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000888800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb00000000000
555500005555000055550000555500000000000000000000000000000000000000000000000000008800009900000000000000000000000000bbbb0044554400
5505000055550000550000005550000000000000000000000000000000000000000000000000000080000009000000000000000000000000000bb00040660400
5555000055050000555000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb00044554400
5500000055050000550000005555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb00040660400
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb040000400
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb044444400
00000000000000000000000000000000000000000000000000000000000000000000000000000000900000080000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000990000880000000000000000000000000000000000000000
55550000555000005505000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55050000505500005505000005500000000000000000000000000000000000000000000000000000000000000000000050005000700070000000000000000000
55500000550500005555000005500000000000000000000000000000000000000000000000000000000000000000000055005500770077000000000000000000
55050000555500005555000055550000000000000000000000000000000000000000000000000000000000000000000055505550777077700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055505550777077700000000000000000
00000000000000000000000000000000000000000000000000000000002244444444220000000000000000000000000055005500770077000000000000000000
00000000000000000000000000000000000000000000000000000000002111111111120000000000000000000000000050005000700070000000000000000000
00000000000000000000000000000000000000000000000000000000004141412141140000000000000000000000000000000000000000000000000000000000
55550000500500005505000055550000777000007707000077070000004112141214140000000000000000000000000000000000000000000000000000000000
55500000550500005505000055000000707700007707000077070000009121414141190000000000000000000000000000000000000000000000000000000000
05550000555500005555000055000000770700007777000077770000009999999999990000000000000000000000000000000000000000000000000000000000
55550000555500000550000055550000777700007777000007700000000211111111200000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000224444222200000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000224444222200000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000db113d000000000000dddb113ddd000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000d13b331d0000000000d1113b33111d00000000000000077777700000000000000000000000
000000000000000bb0bb000000000000024444b444200000000000610110160000000000d1100110011d00000000000000061117000000000000000000000000
0000000000002244b33444220000000020000b330002000000000016666661000000000061000000001600000000000000061170000000000000000000000000
00000000000020000300000200000000404041114004000000000001111110000000000016666666666100000000000000061616000000000000000000000000
0000000000004040111140040000000040020402040400000000000d1111d000000000000d11111111d000000000000000066066700000000000000000000000
00000000000040020402040400000000902040404009000000000066dddddd000000000066dddddddddd00000000000000060007700000000000000000000000
00000000000090204040400900000000099999999990000000000d66dddd6dd00000000d66d6dd6ddd6dd0000000000000000000000000000000000000000000
000000000000999999999999000000000000000000000000000001ddddd6661000000001ddddddd6d66610000000000000000000000000000000000000000000
0000000000000200000000200000000000244222220000000000011ddddd61100000000111dd6ddddd6110000000000000000000000000000000000000000000
00000000000002244442222000000000002442222200000000000011111111000000000011166611111100000000000000000000000000000000000000000000
00000000000002244442222000000000000442222000000000000001111110000000000001116111d11000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000500050000000000000000000000000000000000000000000
00550000000000000000000000000000000000000000000000000000000000000000000000000000550055000000000000000000000000000000000000000000
00555555555555500000000000000000000000000000000000000000000000000000000000000000555055500000000000000000000000000000000000000000
00050000000000500000000000000000000000000000000000000000000000000000000000000000555055500000000000000000000000000000000000000000
00050550550550500000000000000000000000000000000000000000000000000000000000000000550055000000000000000000000000000000000000000000
00050000000000500000000000000000000000000000000000000000000000000000000000000000500050000000000000000000000000000000000000000000
00050055055005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005500005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005500005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00010000000000000028050280501905014050173501535017350173501535013350133502515027150291501e15021150246500d6502b6502b65026150200502005018050180501b05021050240500000000000
00100000000001f6501e6501e6501d6501d6501d6501d6501d6501e6501f650216502265023650000002565026650276502765027650246501f650136501265012650126501565018650166501e6500000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000023650236502365025650000002765000000000002a650000002c650000002f6502f6502c65000000276500000000000226501e6501d6501c6501c6501d6501f650216500000026650286502565000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000e1500e1500e15017650221501c1501815020250202501e250141501d2501b2501a2500c1500c1500d1500e15012150171501d1502115025150191500715007150091501c65024650000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001a6501a6501a6501a6501b6501c6501d6501d650000001a65017650146501365013650000001365000000146500000015650000000000000000156500000000000000001565000000000001565015650
