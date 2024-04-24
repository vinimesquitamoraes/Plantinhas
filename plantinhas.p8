pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--ed rocha te amo =================================================================================================================================================================+
function _init()
 --carrega save 
	cartdata("edevini_plantinhas_1")
 --inicia o mouse -----------------------------------------------------------------------------------------------------------------------------------------------------------------+
 poke(0x5f2d, 1)
 --cus ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
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

 --status -------------------------------------------------------------------------------------------------------------------------------------------------------------------------+	
 --[[
 status
 1 para a tela principal
 2 para loja
 3 para o deposito
 ]]
 status = 1

 --auxiliares ---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 aux_tipo    = 1
 saldo       = 10000
 grav        = 2
	num_atl     = 6	
	max_saturac = 20
	
 --listas -------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 ls_tst = {["tipo"]="teste"       ,["val"]=false,["qual"]=nil}
 ls_bts = {["tipo"]="botao"       ,["val"]=false,["qual"]=nil}
 ls_esp = {["tipo"]="espaco"      ,["val"]=false,["qual"]=nil,["esps"  ]={}                              ,["timer"]=0,["wait"]=false} 
 ls_plv = {["tipo"]="palavra"     ,["val"]=false,["qual"]=nil}
 ls_atl = {["tipo"]="atalho"      ,["val"]=false,["qual"]=nil,["atls"  ]={},["show" ]=false,["timer"]=0,["wait"]=false} 
 ls_car = {["tipo"]="carrinho"    ,["val"]=false,["qual"]=nil,["coisas"]={},["total"]=0    ,["timer"]=0,["wait"]=false} 
 ls_inv = {["tipo"]="inventario"  ,["val"]=true ,["qual"]=nil,["coisas"]={},                ["timer"]=0,["wait"]=false} 
 ls_jrd = {["tipo"]="jardim"      ,["val"]=true ,["qual"]=nil,["coisas"]={},                ["timer"]=0,["wait"]=false} 
 ls_prt = {["tipo"]="prateleiras" ,["val"]=false,["qual"]=nil}

 --listas de particulas -----------------------------------------------------------------------------------------------------------------------------------------------------------+
 pat_sem = {["tipo"]="semente",["val"]=false,["qual"]={} }	
 pat_reg = {["tipo"]="agua"   ,["val"]=false,["qual"]={} }	

 --init de palavras ---------------------------------------------------------------------------------------------------------------------------------------------------------------+
 p1={192,193,193,194,240}
 p2={208,193,192,240}
 p3={208,194,195,209,192,240} 
 p4={210,194,193,241,211,224,240}
 p5={208,224,227,243,211}
 p5={208,224,227,243,211}
 p6={225,226,242}
 p7={244,245,246}
 
 tools   = criar_obj("palavra",0,ls_plv,p1,11,  4)
 pots    = criar_obj("palavra",0,ls_plv,p2,11, 32)
 plants  = criar_obj("palavra",0,ls_plv,p3,11, 60)
 flowers = criar_obj("palavra",0,ls_plv,p4,11, 88)
 price   = criar_obj("palavra",0,ls_plv,p5,17,120)
 buy     = criar_obj("palavra",0,ls_plv,p6,99,118)
 buy_atv = criar_obj("palavra",0,ls_plv,p7,99,118)
 
 --instancias ---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 
 --cursor .........................................................................................................................................................................+
 mouse = criar_obj("mouse",0)
	
 --botoes .........................................................................................................................................................................+
 bt_loja = criar_obj("botao",1,ls_bts)
 bt_volt = criar_obj("botao",2,ls_bts)
 bt_comp = criar_obj("botao",3,ls_bts)
 bt_dept = criar_obj("botao",4,ls_bts)

 --espacos da lojinha .............................................................................................................................................................+
 init_loja()
 
 --atalhos ........................................................................................................................................................................+
 init_atl(num_atl)
 def_pos_atls()
 
 --prateleiras ....................................................................................................................................................................+
 init_prat(4)
	
	--objetos funcionais padrao ------------------------------------------------------------------------------------------------------------------------------------------------------+
	regador = criar_obj("item",17,ls_inv.coisas,nil, 50 ,16)
 --ls_atl.atls[1].item =criar_obj("item",17)
	
 --[[testes @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+
 vaso_change = 5
 que_planta  = 9
 aux_x = 10
 for i=1, 4 do
  teste = criar_obj("item",vaso_change,ls_jrd.coisas,nil, 5 ,80)
  vaso_change += 1
  if(vaso_change>8)vaso_change=5
  teste.planta = (criar_obj("item",que_planta)).fases
  que_planta += 1
  teste.x = aux_x
  add(ls_vas_atv,teste)
  aux_x += 20
 end
 
 criar_obj("item",2,ls_inv.coisas,nil, 20 ,10)
 criar_obj("item",3,ls_inv.coisas,nil, 30 ,40)
 criar_obj("item",4,ls_inv.coisas,nil, 60 ,50)
 criar_obj("item",5,ls_inv.coisas,nil, 80 ,50)
 ls_atl.atls[1].item = criar_obj("item", 5)

 ls_atl.atls[2].item = criar_obj("item", 6)
 ls_atl.atls[3].item = criar_obj("item", 7)
 ls_atl.atls[4].item = criar_obj("item",15)
 ls_atl.atls[5].item = criar_obj("item",17)
 ls_atl.atls[6].item = criar_obj("item", 9)
--]]
end

--update ==========================================================================================================================================================================+
function _update()
	mouse:att()

	foreach(ls_bts,function(obj) cool_down(5,obj) end)
 if(btnp(❎))load_obj()
 if(btnp(🅾️))save_obj(ls_inv.qual)
  
 --atualizar particulas
	att_particulas(pat_sem)
 att_particulas(pat_reg)

 --jogo principal rocha --------------------------------------------------------------------------------------------+	
 if(status == 1)then
  cool_down(5,ls_jrd)
  cool_down(5,ls_atl)
  
  --ir depot .......................................................................................................
  if(ls_atl.show)then
   bt_dept:hover()
   bt_dept:ativa()
  end
  
  --ir loja ........................................................................................................   
  if(not ls_atl.show and not ls_atl.val)then
   bt_loja:hover()
   bt_loja:ativa()
  end
  	
  --colisao atalhos ------------------------------------------------------------------------------------------------------+
  if(ls_atl.show) then
   check_sel_and_mov(ls_atl.atls,ls_atl,"circ")	 
  end
    
 	--colisao jardim -------------------------------------------------------------------------------------------------------+
	 --delay pra comecar a mover
  cool_down(5,ls_jrd)
  if(not ls_atl.show and ls_jrd.wait) then
   check_sel_and_mov(ls_jrd.coisas,ls_jrd,"retg",ls_jrd.val)	 
  end

  --performar atribuicao
  if(ls_atl.show and ls_atl.qual)toggle_atribuir()
  --se o timer contou ja
  if(ls_atl.wait)atribuir()
   
  --regar -------------------------------------------------------------------------------------------------------+
		if(pat_reg.val and not ls_atl.show)then
			if(mouse:toggle(mouse.esq,204,236)) gerar_part(pat_reg, 1, 2, 3, nil, stat(32)+1, stat(33)+13)				
		end
		 
		--esperando awa -------------------------------------------------------------------------------------------------------+ 	
 	foreach(pat_reg,function(obj) regar(obj) end)
  
  --esperando semente -------------------------------------------------------------------------------------------------------+
 	foreach(pat_sem,function(obj) plantar(obj) end)
 
  atl_on_off(mouse.dir_press)	

 --lojinha rocha ---------------------------------------------------------------------------------------------------+				
 elseif(status == 2)then

  --selecionar loja ................................................................................................+
 	foreach(ls_esp.esps,function(esp) esp:hover("retg" ) end)
	 check_sel_and_mov(ls_esp.esps,ls_esp,"retg")										
      
  --selecionar compra ..............................................................................................+
  if(ls_esp.qual)then
   mouse:tip_set(231,"➡️","")
 		ls_esp.qual:add_car()	
  end  
  
  --colisao no carrinho ............................................................................................+
  if(not ls_car.val and #ls_car.coisas >0) then
   foreach(ls_car.coisas,function(esp) esp:hover("retg") end)
   check_sel_and_mov(ls_car.coisas,ls_car,"retg")
  end
   
  --remover carrinho ...............................................................................................+
  if(ls_car.qual)then
   mouse:tip_set(232,"➡️","")
  	ls_car.qual:del_car()	
  end
  			
  bt_comp:hover()
  bt_comp:ativa()			
  bt_volt:hover()
  bt_volt:ativa()
	
  if(not ls_esp.qual and not ls_car.qual)mouse:reset()
		att_car()

 --deposito rocha --------------------------------------------------------------------------------------------------+
 elseif(status == 3)then
  cool_down(5,ls_inv)
  cool_down(5,ls_atl)

  grav_depot()
 
  --checar colisao =================================================================================================+
		--atalhos --------------------------------------------------------------------------------------------------------+
  if(ls_atl.show) then
   check_sel_and_mov(ls_atl.atls,ls_atl,"circ")	 
  end
  
		--inventario -----------------------------------------------------------------------------------------------------+
	 --delay pra comecar a mover
		if(not ls_atl.show and ls_inv.wait) then
   check_sel_and_mov(ls_inv.coisas,ls_inv,"retg",ls_inv.val)	 
  end
	
  --performar atribuicao
  if(ls_atl.show and ls_atl.qual)toggle_atribuir()
  --se o timer contou ja
  if(ls_atl.wait)atribuir()
  atl_on_off(mouse.dir_press)	
     
  if(ls_atl.show)then
   bt_dept:hover()
   bt_dept:ativa()
  end

 end

end

--draw =============================================================================================================+
function _draw()
 cls()
 if(true) then
	 format(cu1,str1,3)
	 format(cu2,str2,3)
		
	 format(cu3,str3,12)
	 format(cu4,str4,12)
	 	 --[[
	 format(cu5,str5,9)
	 format(cu6,str6,9)
	 
	 format(cu7,str7)
	 format(cu8,str8)
	 --
	 format(cu9,str9)
	 --]]
	 espacamento =0
	end
 --jogo principal --------------------------------------------------------------------------------------------------+
 if(status == 1)then
  bt_loja:des()
  des_jardim()
  
  --particulas -----------------------------------------------------------------------------------------------------+
  des_particulas(pat_sem)
 	des_particulas(pat_reg)
 	
 	--atalhos --------------------------------------------------------------------------------------------------------+	
  des_atl()
  debug_obj(ls_jrd.qual)

 --loljinha --------------------------------------------------------------------------------------------------------+
 elseif(status == 2)then
  des_lojinha()
 
 --deposito -------------------------------------------------------------------------------------------------------+
 elseif(status == 3)then
  des_depot()
  des_atl()
  debug_obj(ls_inv.qual)

 end

 mouse:des()
	if(false) pos_mouse(10)


end

function format(que_cu,str,cor)
 str = str or ""
 cor = cor or 5	
 print(str..tostr(que_cu),0,espacamento,cor)
 espacamento+=6	
end

-->8
--classes ==========================================================================================================+
function criar_obj(que_classe,subtipo,ls_guardar,ls_aux,xop,yop)
 novo_obj = {
  --atributos ------------------------------------------------------------------------------------------------------+
	 onde     = 0,
  x				    = xop or 0,
  y 			    = yop or 0,
  cla      = que_classe,
  tip      = 0,
  algo     = 0,
  s        = 0,
  cur_s    = 0,
  w        = 8,
  h        = 8,
  r        = 1,
  n        = 0,
  xoff     = 0,
  yoff     = 0,
  hoff     = 0,
  woff     = 0,
 	y_vel    = 1,
  movable  = false,
  contble  = false,
  ct       = 0,
  id       = 0,
  ls_gua   = ls_guardar,
  ls_aux   = ls_aux or nil,
  --metodos--------------------------------------------------------------------------------------------------------+ 
  foi_onde = function(self,pra_onde)
 		if(    pra_onde == "jardim")then	 		
				self.onde = 0
			elseif(pra_onde == "inventario")then
				self.onde = 1			
			elseif(pra_onde == "atalho")then
		 	self.onde = 2
			else
  	 self.onde = 3
			end		
		end,
				
  --mover objeto ..................................................................................................+
  mov = function(self, newx, newy)
   self.x = newx& ~1
   self.y = newy& ~1
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
	 mov_cur = function(self,contexto,pode_mover)
			if(contexto and self.movable and pode_mover)self:mov((stat(32) - flr(self.w/2)),(stat(33) - flr(self.w/2)))
			n_sai_tela(self)
			return que_botao
	 end,

	 --checa colisao entre algo e 
		--o cursor
  col_mouse =	function(self,tipo)
			if(tipo == "retg")then
				--checar entre direita e esquerda, cim e baixo
				esq =  self.x+self.xoff
				dir = (self.x+self.xoff)+(self.w-self.woff)
				cim =  self.y+self.yoff
				bax = (self.y+self.yoff)+(self.h-self.hoff)
					
				return (stat(32)>=esq and (stat(32)) <= dir) and
       				(stat(33)>=cim and (stat(33)) <= bax)
	 	
			elseif(tipo == "circ")then
				dx   = self.x - stat(32)
				dy   = self.y - stat(33)
				dist = flr(sqrt((dx*dx)+(dy*dy)))
				return dist <= self.r				
				
	 	end
	 
 end	
	}
	
 def_tip(novo_obj,subtipo,ls_guardar) 

 add(ls_guardar,novo_obj)

 return novo_obj
end
-->8
--def_tipos ====================
function def_tip(self,subtipo)

--mouse ========================		 
	if(self.cla == "mouse")then
  self.ativ      = true
 	self.s         = 212
		self.ct        = 1
			
		--esperando ==================
 	self.esq_esper = false
 	self.mei_esper = false
 	self.dir_esper = false
		
		--pressionado ================
 	self.esq_press = false
 	self.mei_press = false
 	self.dir_press = false
		
		--estado atual ======================
 	self.esq = false
 	self.mei = false
 	self.dir = false

		--solto ======================
 	self.esq_solto = false
		self.mei_solto = false
		self.dir_solto = false
		
	--resetar mouse ===============
 function self:reset()
	 self.s        = 212
	 self.tool_tip = nil
	 self.h        = 8
	 self.w        = 8	
	 self.ct       = 1
	end
	
	--mudar tool_tip
	function self:tip_set(qual,dir_x,dir_y)
	 self.tool_tip = qual or nil	
 	dir_x,dir_y = dir_x,dir_y

		if(dir_x == "⬅️")then
		 self.xoff = -8		
		elseif(dir_x == "➡️")then
			self.xoff =  8
		else
			self.xoff =  0
		end

		if(dir_y == "⬆️")then
		 self.yoff = -9		
		elseif(dir_y == "⬇️")then
			self.yoff =  9
		else
			self.yoff =  0
		end

	end
 	 
	--desenhar mouse ==============
 function self:des()
  pal(self.ct,0)
  spr(self.s,stat(32),stat(33),self.w/8,self.h/8)
 	if(self.tool_tip)spr(self.tool_tip,stat(32)+mouse.xoff,stat(33)+mouse.yoff)
		pal()
 end
 
 function self:toggle(que_bt,spr_1,spr_2)
 	if(que_bt)then
 	 mouse.s = spr_2
 	 return true
 	end
  mouse.s = spr_1
	 return false
 end
 
 --atualizar mouse =============
 function self:att()
 	--att posicao ================
 	self.x = stat(32)
 	self.y = stat(33)
 	--att posicao ================
		self.esq= stat(34)==1
		self.mei= stat(34)==4
		self.dir= stat(34)==2
	
		--comportamento esquerdo ||||
		--se o mouse esq foi apertado
		if(self.esq)then
			--se ele estava solto
			if(self.esq_solto)then
				--agora nao esta mais
				self.esq_solto=false
			end
			
			--se ele nao estava pressio
			--nado
			if(not self.esq_press)then
		 	--se nao estava esperando
				if(not self.esq_esper) then
		 		--agora esta pressionado
		 		--e esperando
					self.esq_press = true
					self.esq_esper = true
				end
			--se ja estava pressionado
			else
				--agora no esta mais
				self.esq_press = false
			end
			
		--se o mouse esq nao foi
		--apertado
		else
		--se estava pressionado
			if (self.esq_press) then
				--agora nao esta mais
				self.esq_press=false
			end
			
			--se nao esatava solto
			if(not self.esq_solto)then
				--se estava esperando
				if(self.esq_esper)then
					--agora esta solto
					self.esq_solto = true
					--e nao esta mais esperando
     self.esq_esper = false
    end
   --se estava solto
   else
   	--agora nao esta mais
   	self.esq_solto = false
   end
	 end
		
 	--comportamento meio ||||||||
		--se o mouse mei foi apertado
		if(self.mei)then
			--se ele estava solto
			if(self.mei)then
				--agora nao esta mais
				self.mei_solto=false
			end
			
			--se ele nao estava pressio
			--nado
			if(not self.mei_press)then
		 	--se nao estava esperando
				if(not self.mei_esper) then
		 		--agora esta pressionado
		 		--e esperando
					self.mei_press = true
					self.mei_esper = true
				end
			--se ja estava pressionado
			else
				--agora no esta mais
				self.mei_press = false
			end
			
		--se o mouse mei nao foi
		--apertado
		else
		--se estava pressionado
			if (self.mei_press) then
				--agora nao esta mais
				self.mei_press=false
			end
			
			--se nao esatava solto
			if(not self.mei_solto)then
				--se estava esperando
				if(self.mei_esper)then
					--agora esta solto
					self.mei_solto = true
					--e nao esta mais esperando
     self.mei_esper = false
    end
   --se estava solto
   else
   	--agora nao esta mais
   	self.mei_solto = false
   end
	 end
	 
 	--comportamento direita ||||||
		--se o mouse dir foi apertado
		if(self.dir)then
			--se ele estava solto
			if(self.dir)then
				--agora nao esta mais
				self.dir_solto=false
			end
			
			--se ele nao estava pressio
			--nado
			if(not self.dir_press)then
		 	--se nao estava esperando
				if(not self.dir_esper) then
		 		--agora esta pressionado
		 		--e esperando
					self.dir_press = true
					self.dir_esper = true
				end
			--se ja estava pressionado
			else
				--agora no esta mais
				self.dir_press = false
			end
			
		--se o mouse dir nao foi
		--apertado
		else
		--se estava pressionado
			if (self.dir_press) then
				--agora nao esta mais
				self.dir_press=false
			end
			
			--se nao esatava solto
			if(not self.dir_solto)then
				--se estava esperando
				if(self.dir_esper)then
					--agora esta solto
					self.dir_solto = true
					--e nao esta mais esperando
     self.dir_esper = false
    end
   --se estava solto
   else
   	--agora nao esta mais
   	self.dir_solto = false
   end
	 end
	end

--particula ====================
	elseif(self.cla == "particula")then
		self.vx    = rnd(2) - 1
 	self.vy    = 1
		self.x_max = 128
		self.x_mix = 0
		self.w     = 0
		self.h     = 0

 	if(subtipo == 1)then
 		self.cor = 3
		 self.ace = 0
 	elseif(subtipo == 2)then
 		self.cor = 12
		 self.ace = 0.2
 	end

		function self:att()			
			self.x  +=	self.vx
			self.y  += flr(self.vy)
  	self.vy += self.ace
  	
			if(self.x>self.x_max)then
				self.x = self.x_max
				
			elseif(self.x<self.x_min)then
				self.x  = self.x_min
				self.vx = -self.vx
			end
			
			if(saiu(self))then
				pat_sem.val = false
				self:del()
			end
		end
		
		function self:des()
	  pset(self.x,self.y,self.cor)
	 end
	 
	 function self:del()
			if(self)then
		 del(self.ls_gua, self)
	  self = nil
			end
			return true

	 end
	
--botao ========================		 
	elseif(self.cla == "botao")then
		self.timer = 0
		self.wait  = false
		self.val   = true
		 
		--lojinha
		if(subtipo == 1)then
 		self.tip       = 1
			self.x		       = 1
			self.y         = 113
	  self.w,self.h  = 16,16
	  self.tam       = 2
	  self.s,self.sr = 14,14
		 self.sp        = 46
		 self.ct        = 1
		 
	 --voltar
		elseif(subtipo == 2)then
			self.tip       = 2
			self.x		       = 1
			self.y         = 113			
	  self.w,self.h  = 16,16
	  self.tam       = 2
	  self.s,self.sr = 12,12
		 self.sp        = 44
		 self.ct        = 0

		--comprar
		elseif(subtipo == 3)then
 		self.tip            = 3
			self.x	            	= 97
			self.y              = 116 		
			self.w              = 18
	  self.h              = 8
	  self.cor1,self.cor3 = 5,5
	  self.cor2           = 10

	 --depot
		elseif(subtipo == 4)then
 		self.tip       = 4
			self.x,self.y  = 57,57		
			self.w,self.h  = 16,16
	  self.tam       = 2
   self.s,self.sr = 40,40
		 self.sp        = 42
	  self.ct        = 1
	  
		elseif(subtipo == 5)then
 		self.tip       = 5
			self.x,self.y  = 80,113		
			self.w,self.h  = 8,8
	  self.tam       = 1
   self.s,self.sr = 236,236
		 self.sp        = 237
	 end
	 
	 --metodos de botoes
	 
	 --ativar botao
		function self:ativa()
			--teve colisao
			--mouse esquerdo pressionado			
			if(self:col_mouse("retg") and not(mouse.eq_press) and mouse.esq_press and self.wait)then
				--funcoes ===================
				--ir lojinha
				if(self.tip == 1)then
					status = 2		
	   	mouse:reset()
	  			 
				--voltar jogo principal
				elseif(self.tip == 2)then
					status = 1
					 	 
				--comprar
				elseif(self.tip == 3)then		
					comprar()				
							 
				--ir depot
				elseif(self.tip == 4 and not ls_atl.val)then
					if(status==1)then
						status      = 3
						bt_dept.s   = 12
						bt_dept.sr  = 12
						bt_dept.sp  = 44
						self.ct     = 0
						ls_inv.wait = false
						
					elseif(status==3)then
						bt_dept.s   = 40
						bt_dept.sr  = 40
						bt_dept.sp  = 42
						status      = 1
						ls_atl.val  = false
						self.ct     = 1
					 ls_jrd.wait = false
     	ls_atl.qual = nil      	
					end					
					ls_atl.show = false
					foreach(ls_bts,function(obj) obj.wait = false end)
				end
			end
		end
		
		function self:hover()
			
			if(self:col_mouse("retg") and self.wait)then

				if(self.tip == 3 and count(ls_car.coisas)>0)then				
				 self.cor1 =	self.cor2
				else
				 self.cor1 =	self.cor3
					self.s    = self.sp
				end
	
			else
			
			 self.cor1 =	self.cor3
				self.s    = self.sr	
			
			end
		end
	
	elseif(self.cla == "espaco")then
		self.w,self.h = 18,18
 	self.tam      = 16
 	self.disp     = true
 	if(range(subtipo,1,2))then
 		function self:des()
    rect(self.x,self.y,self.x+self.w-1,self.y+self.h-1,self.cor1)	
	   rectfill(self.x+1,self.y+1,(self.x+self.w-1)-1,(self.y+self.h-1)-1,0)	
    self.item:des(self.x+1,self.y+1)
    if(not self.disp)then
 	   line(self.x+3 ,self.y+2,self.x+14,self.y+13,8)
 	   line(self.x+3 ,self.y+3,self.x+14,self.y+14,8)
	   	line(self.x+3 ,self.y+4,self.x+14,self.y+15,8)
    end
    des_vertices(self.x+1,self.y+1,self.w-2,self.h-2,self.cor1)
			end
		end
 	--espaco da loja
 	if(subtipo == 1)then
 	 self.cor1,self.cor3 = 1,1
	 	self.cor2  = 7

	 	function self:disp_toggle(qual)
 			self.disp = qual or false
			end
					 
		 function self:add_car()
				if(mouse.esq_press)then
				--adiciona ao carrinho
					if(#ls_car.coisas<4)then
				 	if(self.disp)then
					  new_car       = criar_obj("espaco",2,ls_car.coisas)
							new_car.item  = criar_obj("item",self.item.tip)
							ls_car.total += self.item.val
						end
			 	end
			 end
			end
			
		--carinho	
 	elseif(subtipo == 2)then
			self.cor1,self.cor3 = 1,1
	 	self.cor2 = 8
	 	
	 function self:del_car()
	 	if(mouse.esq_press)then
				ls_car.total -= self.item.val
			 del(ls_car.coisas,self)
			 ls_car.qual = nil
			end
	 end
	 	
		--atalho
 	elseif(subtipo == 3)then
 		self.x,self.y = 64,64
	 	self.w,self.h = 16,16
		end

		function self:hover(tip_col)

			if(self:col_mouse(tip_col))then
				 self.cor1 = self.cor2
			else
				 self.cor1 = self.cor3
				 self.qual = nil
				 self.val  = false
			end
			
		end
		
	elseif(self.cla == "prateleira")then			
			self.h = 1
			self.w = 80

	elseif(self.cla == "item")then				
		self.w  = 16
		self.h  = 16
		self.movable = true
		--pa
		if(subtipo == 1)then
 		self.tip   = 1
		 self.val   = 2000
		 self.nome  = "inv slot"
		 self.s     = 2
		 self.xoff  = 2
			self.yoff  = 2
 	 self.woff  = 5
 		self.hoff  = 5
	 	self.cur_s = 214
	  self.ct    = 1

		--regador
	 elseif(subtipo == 2)then
 	 self.tip   = 2
	  self.val   = 500
		 self.nome  = "fertilizer"
		 self.s     = 8
		 self.xoff  = 3
			self.yoff  = 1
 	 self.woff  = 7
	 	self.hoff  = 4
	 	self.cur_s = 216
	  self.ct    = 1	
			self.capacity  = 0
			
		--borrifador
	 elseif(subtipo == 3)then
 		self.tip   = 3
	  self.val   = 400
		 self.nome  = "pesticide"
		 self.s     = 6
		 self.xoff  = 3
			self.yoff  = 1
 	 self.woff  = 7
	 	self.hoff  = 4
	 	self.cur_s = 229
			self.capacity  = 0
			
		--cesta	 	
	 elseif(subtipo == 4)then
	 self.tip    = 4
		 self.val   = 300
		 self.nome  = "basket"
		 self.s     = 4
		 self.xoff  = 0
			self.yoff  = 6
 	 self.woff  = 1
	 	self.hoff  = 8
	  self.ct    = 1
	 	self.cur_s = 215
			self.capacity  = 0
			
	 --vasos rocha
	 elseif(range(subtipo,5,8))then
	 	self.estagio = 1
			self.colher  = false
			self.saturac = 0
			self.cur_s   = 230
			
  	function self:des_planta()
  		local aux = self.planta.wh[self.estagio][1]
		  pal(self.planta.ct,0)
  		if(aux > 1)then
  		 spr(self.planta[self.estagio],self.x          ,self.yp-(self.planta.wh[self.estagio][2]*8),self.planta.wh[self.estagio][1],self.planta.wh[self.estagio][2])
  		else
  		 spr(self.planta[self.estagio],self.x+self.xesp,self.yp-(self.planta.wh[self.estagio][2]*8),self.planta.wh[self.estagio][1],self.planta.wh[self.estagio][2])
  		end
				pal()

  	end
  	
  	function self:vasar()
  		gerar_part(pat_reg, 1, 2, 3, nil,self.x+4 ,self.y+self.h-2)
  		gerar_part(pat_reg, 1, 2, 3, nil,self.x+11,self.y+self.h-2)				  		
  	end
  	
  	function self:des(xop,yop)
  		self.x = xop or self.x
		 	self.y = yop or self.y
		 	--cordenadas onde planat fica no vaso		 	
		 	self.xp = self.x+self.xpoff
		 	self.yp = self.y+self.ypoff

		  pal(self.ct,0)
		 	spr(self.s,self.x,self.y,self.w/8,self.h/8)
				pal()
				
				if(self.planta)self:des_planta()
  	end
			
			--vaso1
		 if(subtipo == 5)then
	 	 self.tip  = 5
			 self.val  = 500
			 self.nome = "flowerpot 1"
			 self.s    = 32
			 self.xoff = 2
				self.yoff = 5
	 	 self.woff = 5
		 	self.hoff = 8
		  self.ct   = 1

		  --cordenadas da plnat no vaso
		  self.xpoff = 8 
		  self.xesp  = 4
		  self.ypoff = 8
		
			--vaso2
		 elseif(subtipo == 6)then
		  self.tip  = 6
			 self.val  = 500
			 self.nome = "flowerpot 2"
			 self.s    = 34
			 self.xoff = 2
				self.yoff = 5
	 	 self.woff = 5
		 	self.hoff = 7
		  self.ct   = 1
		 
		  self.xpoff = 8
		  self.xesp  = 4
		  self.ypoff = 7
		 			 
			--vaso3
		 elseif(subtipo == 7)then
		  self.tip  = 7
			 self.val  = 600
			 self.nome = "flowerpot 3"
			 self.s    = 36	
			 self.xoff = 3
				self.yoff = 2
	 	 self.woff = 7
		 	self.hoff = 5
		  self.ct   = 2
		 	
		  self.xpoff = 8
		  self.xesp  = 4
		  self.ypoff = 5
		 		
			--vaso4
		 elseif(subtipo == 8)then
		  self.tip  = 8
			 self.val  = 600
			 self.nome = "flowerpot 4"
			 self.s    = 38
			 self.xoff = 1
				self.yoff = 2
	 	 self.woff = 3
		 	self.hoff = 5
		  self.ct   = 2
		 
		  self.xpoff = 8
		  self.xesp  = 4
		  self.ypoff = 5
		  
	 	end	
		--planta1
	 elseif(range(subtipo,9,18))then
		 self.s     = 10
		 self.ct    = 1
		 self.xoff  = 2
			self.yoff  = 2
 	 self.woff  = 5
	 	self.hoff  = 5
	 	self.cur_s = 249

		 if(subtipo == 9)then
		  self.tip  = 9
			 self.val  = 400
			 self.nome = "tomato"
		 	self.fases= {70   ,71   ,87   ,85   ,72   ,104 ,
           wh = {{1,1},{1,1},{1,2},{2,2},{2,2},{2,2}},
          tip = self.tip-8}
		 		 
			--planta2
		 elseif(subtipo == 10)then
		  self.tip  = 10
		  self.val  = 500
			 self.nome = "bear_pawn"		
		 	self.fases= {64   ,65   ,66   ,67   ,68   ,74   , 
           wh = {{1,1},{1,1},{1,1},{1,1},{2,1},{2,2}},
          tip = self.tip-8}					 
			  	
			--planta3
		 elseif(subtipo == 11)then
		  self.tip  = 11
		  self.val  = 600
			 self.nome = "pumpkin"
		 	self.fases= {96   ,97   ,114  ,115  ,117  ,168  ,136  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,1},{2,2},{2,2}},
          tip = self.tip-8}			 
			  				 		 	
		 --planta4
		 elseif(subtipo == 12)then
		  self.tip  = 12
		  self.val  = 1000
			 self.nome = "pegaxi"		
 	 	self.fases= {96   ,97   ,114  ,115  ,117  ,106  ,108  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,1},{2,2},{2,2}},
          tip = self.tip-8}				 
  				 		 			  	
		 --planta5
		 elseif(subtipo == 13)then
		  self.tip  = 13
		  self.val  = 500
			 self.nome = "sunflower"
			 self.fases= {96   ,80   ,81   ,82   ,83   ,84   ,
           wh = {{1,1},{1,1},{1,1},{1,2},{1,2},{1,2}},
          tip = self.tip-8} 					 
		
		 --planta6
		 elseif(subtipo == 14)then
		  self.tip  = 14
		  self.val  = 350
			 self.nome = "sword"		 	
			 self.fases= {64   ,112  ,113   ,130 ,132  ,134  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,2},{2,2}},
          tip = self.tip-8} 					 
				self.fases.ct = 2

		 --planta7
		 elseif(subtipo == 15)then
		  self.tip  = 15
		  self.val  = 600
			 self.nome = "rose"
			 self.fases= {70   ,176  ,177  ,162  ,163  ,164  ,165  ,
           wh = {{1,1},{1,1},{1,1},{1,2},{1,2},{1,2},{1,2}},
          tip = self.tip-8} 					 
				self.fases.ct = 2
				
		 --planta8
		 elseif(subtipo == 16)then
		  self.tip  = 16
		  self.val  = 1000
			 self.nome = "dandelion"
			 self.fases= {70   ,128  ,129  ,146  ,138  ,140  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,2},{2,2}},
          tip = self.tip-8}					 
		
			--regador
		 elseif(subtipo == 17)then
	 	 self.tip  = 17
		  self.val  = 500
			 self.nome = "watering can"
			 self.s    = 204
			 self.s2   = 236
			 self.s3   = 204
			 self.xoff = 3
				self.yoff = 1
	 	 self.woff = 7
		 	self.hoff = 4
		 	self.cur_s = 248

		 end 
		end
	
	--palavra	
	elseif(self.cla == "palavra")then				
  self.w    = count(self.ls_aux)
 	self.h    = 4
	 self.cor1 = 5
		self.cor2 = 5
 	function self:des()
			local aux = 0
			for i in all(self.ls_aux)do
				spr(i,self.x+aux,self.y)
				aux +=5
			end
		end
			
	end
	
end

-->8
--colisor e utilitrios =========
--nao deixa um objeto sair
--da tela
function n_sai_tela(oque)
	if(oque != nil)then
		esq = oque.x+oque.xoff
		cim = oque.y+oque.yoff
		dir = esq+oque.w-oque.woff
		bax = cim+oque.h-oque.hoff
	
		if(esq <   0) oque.x = -oque.xoff
		if(cim <   0) oque.y = -oque.yoff
 	if(dir > 127) oque.x = oque.x+(127-dir)
 	if(bax > 127) oque.y = oque.y+(127-bax)-1
	end
end

--saiu da tela
function saiu(oque)
	if(oque != nil)then
		esq = oque.x+oque.xoff
		cim = oque.y+oque.yoff
		dir = esq+oque.w-oque.woff
		bax = cim+oque.h-oque.hoff
			
		if(esq < 0) return true
		if(cim < 0) return true
 	if(dir > 127) return true
 	if(bax > 127) return true
 	return false
	end
end

--checa colisao entre dois retangulos
function col_2ret(q1,q2)
	esq_1 = q1.x+q1.xoff
	cim_1 = q1.y+q1.yoff
	dir_1 = esq_1+q1.w-q1.woff
	bax_1 = cim_1+q1.h-q1.hoff
	
	esq_2 = q2.x+q2.xoff
	cim_2 = q2.y+q2.yoff
	dir_2 = esq_2+q2.w-q2.woff
	bax_2 = cim_2+q2.h-q2.hoff

	--checar entre direita e esquerda
	if(esq_1 < dir_2 and dir_1 > esq_2)then
  if(cim_1 < bax_2 and bax_1 > cim_2)then
			return true
		end
	end

	return false	
	
end

--colisao de dois circulos
function col_circ(q1,q2)
	dx   = q1.x - q2.x
	dy   = q1.y - q2.y
	dist = sqrt((dx*dx)+(dy*dy))
	if(dist <= (q1.r+q2.r))then
		return true
	end
	
	return false
	
end

--colisa de um circulo e 1 ponto
function col_circ_pt(cic,pt)
	dx   = cic.x - pt.x
	dy   = cic.y - pt.y
	dist = flr(sqrt((dx*dx)+(dy*dy)))
	if(dist <= (cic.r))then
		return true
	end
	
	return false
	
end

--retorna o obejto selecionado
--em uma lista
function get_obj_by_col_mos(lista,tipo)
	
	for qual in all(lista)do
		
		if(qual:col_mouse(tipo))return qual
				
	end	

end

function get_obj_by_col_retg(ls_oque_1,oque_2)
	
	for qual in all(ls_oque_1)do
		col = col_2ret(qual,oque_2)		if(col)return qual
		if(col)return qual
	end	
	return nil
end

--checa a selecao de objetos
--em uma lista
--se um deles ja estiver sido 
--nao  checado
function check_sel_and_mov(qual_ls,controle,tipo,pode_mover)
 pode_mover = pode_mover or false

 --se tem alguem selecionado
	if(controle.qual)then
		if(not controle.qual:mov_cur(mouse.esq,pode_mover) and not controle.qual:col_mouse(tipo)) controle.qual = nil
  if(controle.qual and stat(34)==3)then
   add(qual_ls,del(qual_ls,controle.qual))
  end
	--se nao tem ninguem selecionado
	else
		controle.qual = get_obj_by_col_mos(qual_ls,tipo) 
	end
	
end

--desenhar vertice
function des_vertices(x,y,w,h,cor)

 pset(x    ,y    ,cor)
 pset(x+w-1,y    ,cor)
 pset(x    ,y+h-1,cor)
 pset(x+w-1,y+h-1,cor)

end

--exibe x y do mouse
function pos_mouse(cor)
		print("("..stat(32)..","..stat(33)..")",100,120,cor)
end

--apaga uma lista
function del_ls(qual_ls)
	for i in all(qual_ls)do
		del(qual_ls,i)
	end
end

--particulas
function des_particulas(que_ls)
	foreach(que_ls,function(p) p:des() end)
end

--atualizar prticulas
function att_particulas(que_ls_part)
	
 for p in all(que_ls_part) do
 	p:att() 
 	if(#que_ls_part>0 and que_ls_part.tipo == "semente")ls_jrd.val = false
 end 

 if(#que_ls_part==0 and que_ls_part.tipo == "semente")ls_jrd.val = true
		 
end

function gerar_part(que_pat_ls, quantas, tip, ampx, item, x, y)
 tip = tip or 1
 for i=1, quantas do
		nova = criar_obj("particula",tip,que_pat_ls,item)
		nova.x     = x
		nova.y     = y
		nova.x_max = nova.x+ampx
		nova.x_min = nova.x-ampx
	end
end

function range(val,⬅️,➡️)
	if(val >= ⬅️ and val <= ➡️)return true
	return false
end

function cool_down(tempo,context)

	if context.val and not context.wait then

		if(context.timer>=tempo)then
		 context.wait  = true
  	context.timer = 0
 	else		
 		context.timer += 1
 	end
		
	end
	
end
-->8
--loljinha =====================
function	des_lojinha()
 --base
	rect(8,2,119,114,5)
	line(92,114,118,114,0)
	--compartimentos			
	rect(37,7,91,28,5)
	rect(32,35,91,55,5)
	rect(42,63,91,83,5)
	rect(47,91,91,114,5)
	
	--linhas do lado labels
	rect(35,30,91,32,5)
	rect(35,31,90,32,0)
	
	rect(45,58,91,60,5)
	rect(45,59,90,60,0)

	rect(50,86,91,88,5)
	rect(50,87,90,88,0)
 
 --tools
 rect(8,2,37,28,5)
 rectfill(9,3,36,27,0)
 rectfill(8,28,91,29,0)
 
 --pots
	local addy = 28
 rect(8,2+addy,32,28+addy,5)
 rectfill(9,36,90,55,0)
 rectfill(8,56,91,57,0)
 
 --plants
 addy +=28
 rect(8,2+addy,42,28+addy,5)
 rectfill(9,64,90,83,0)
 rectfill(8,84,91,85,0)
 
 --flowers
 addy +=28
 rect(8,2+addy,47,28+addy,5)
 rectfill(9,92,90,113,0)
	rectfill(9,112,90,113,0)
	
	--do lado dos labels			
	rect(38,2,39,6,0)
	line(37,8,37,9,0)
	line(32,36,32,37,0)
	line(42,64,42,65,0)
	line(47,92,47,93,0)
	
	--botao de comprar
	rect(92,114,119,126,5)
	rectfill(92,114,118,125,0)
	des_vertices(95,115,22,10,5)
	
	--carrinho de compra
	local y=0
	for i=1,4 do
		rect(95,7+y,116,28+y,5)
		des_vertices(98,10+y,16,16,5)
		y+=28
	end
	
	--precos
 rect(14,117,91,126,5)
 rectfill(15,118,90,125,0)
 rect(14,117,66,126,5)
 
 tools:des()
	pots:des()
 plants:des()
 flowers:des()

	foreach(ls_esp.esps,function(obj) obj:des() end)
	foreach(ls_car.coisas,function(obj) obj:des() end)

 tool_tip()
 des_bt_comprar()
 bt_volt:des()
 
end

--cria vitrines
function init_loja()

	for i=1,16 do      
  aux      = criar_obj("espaco",1,ls_esp.esps)
		aux.item = criar_obj("item"  ,aux_tipo)
		aux_tipo+=1		
		aux.id = i
	end	
	
 ondex,ondey =	11,10
 for i in all(ls_esp.esps)do
		i.x = ondex
		i.item.x = i.x+1
		i.y = ondey
		i.item.y = i.y+1
		ondex += 20
		
		if(i.id%4==0)then
			ondey+=28
			ondex =11
		end
	end	
end

--on/off disponibilidade
function toggle_disp(qual,pra_qual)
 ls_esp.esps[qual]:disp_toggle(pra_qual)
end

--desenha o carrinho de compras
function att_car()

	if(count(ls_car.coisas)>0)then
		local aux_y = 9
		for i in all(ls_car.coisas) do
		 i.x    = 97
			i.y    = aux_y
			aux_y += 28
		end	
	end
	
end

function des_bt_comprar()
	rect(bt_comp.x,bt_comp.y,bt_comp.x+bt_comp.w-1,bt_comp.y+bt_comp.h-1,bt_comp.cor1)	
	if(not bt_comp:col_mouse("retg"))then
			buy:des()
	else
		if(#ls_car.coisas>0)then
		 buy_atv:des()
		else
			buy:des()
		end
	end
end

function tool_tip()
	--mostrar preco ao passar mouse	
	if(ls_esp.qual)then
		auxtip = ls_esp.qual.item.tip
		--nome do item
		if(auxtip >=9 and auxtip <=16)then
			print("seeds",17,120,6)			
		else
			print(ls_esp.qual.item.nome,17,120,6)
		end
		--preco
		local cor = 8
		if(ls_esp.qual.item.val > saldo) cor = 8
  print(ls_esp.qual.item.val,69,120,cor)
	
	elseif(bt_comp:col_mouse("retg") and ls_car.total!=0 )then
			local cor = 10
			print("total",17,120,10)
			if(ls_car.total > saldo) cor = 8
	  print(ls_car.total,69,120,cor)
	
	--mostrar preco ao passar mouse no carrinho
	elseif(ls_car.val)then
	
		if(ls_car.qual != nil)then			
			print(ls_car.qual.item.nome,17,120,6)
	  print(ls_car.qual.item.val,69,120,6)
 	end

	--mostrar saldo 	
	else
		print("money",17,120,6)
		print(saldo  ,69,120,3)
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
		foreach(ls_inv.coisas,function(obj) obj:des() end)
	else
		foreach(ls_jrd.coisas,function(obj) obj:des() end)
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
	
	if(status == 2) def_pos(qual)
	if(onde   == 1)then
	 add(ls_jrd.coisas,qual)
	 qual:foi_onde("jardim")
	else
	 qual:foi_onde("inventario")
  add(ls_inv.coisas,qual)
 end
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
function init_atl(quantos_pares)	
	quantos = quantos_pares& ~1

	if(quantos>8) quantos = 8
	if(quantos<2) quantos = 2
	
	if(#ls_atl.atls+quantos>8)return
	
	for i=1,quantos do
 	new_atl      =	criar_obj("espaco",3,ls_atl.atls)  	 
	 new_atl.item = nil
		new_atl.cor1 = 1 	
		new_atl.cor2 = 7
		new_atl.cor3 = 1
		new_atl.id   = #ls_atl.atls
		new_atl.r    = 8.5
	end

end

function def_pos_atls()

	for i in all(ls_atl.atls)do
  i.x =	64
	 i.y = 64
	end

 local angulo = 0

	quantos = #ls_atl.atls
 	
	if(quantos == 2)then
	 ang_inc = 60
	 dist    = 20
	elseif(quantos == 4)then
	 ang_inc = 90
	 dist    = 20
	elseif(quantos == 6)then
	 ang_inc = 60
	 dist    = 24
	elseif(quantos == 8)then
	 ang_inc = 45
	 dist    = 28
	end
	
	for i in all(ls_atl.atls)do
  i.x =	i.x - dist * sin(angulo/360)
	 i.y =	i.y - dist * cos(angulo/360) 
		angulo += ang_inc
	end

end

function des_atl()

	if(ls_atl.show)then
		for i in all(ls_atl.atls)do
		 ovalfill(i.x-9, i.y-9,i.x+10,i.y+10,0)
   ovalfill(i.x-8, i.y-8,i.x+9 ,i.y+9 ,0)
   oval(i.x-8, i.y-8,i.x+9,i.y+9,i.cor1)

			if(i.item !=nil)then
			 i.item:des(i.x-7,i.y-7)
			end
 		i:hover("circ")
		end  	
		
  bt_dept:des()
	end

end

--mostrar-ocultar atalhos
function atl_on_off(context)

	if(context)then
		ls_atl.show = not ls_atl.show 
		
		if(ls_atl.show)then 
			mouse:reset()

			ls_jrd.val   = true
			ls_inv.val   = true
			
			ls_jrd.qual  = nil
			ls_inv.qual  = nil
			
			ls_atl.val   = false
			ls_atl.wait  = false
			ls_atl.timer = 0
			
			pat_reg.val  = false
			
			foreach(ls_bts,function(obj) obj.wait = false end)

		end
		
	end	
		
end

function toggle_atribuir()
	
	if(mouse.esq_press)then	
  --oculta os atalhos
	 atl_on_off(true)
	 --poe em contexto de atribuicao
		ls_atl.val = true
		--desativa o movimento do jardim e inventario
		ls_jrd.val,ls_inv.val = false,false				
		
		if(status == 3)then
			if(ls_atl.qual and ls_atl.qual.item)then
	   mouse:tip_set(ls_atl.qual.item.cur_s,"⬅️","⬆️")
	 	else
	   mouse:tip_set(217,"⬅️","⬆️")
	 	end
	 else
	 	if(ls_atl.qual and ls_atl.qual.item and range(ls_atl.qual.item.tip,5,8))then
	   mouse:tip_set(ls_atl.qual.item.cur_s,"⬅️","⬆️")
	 	end
	 	if(ls_atl.qual and ls_atl.qual.item and ls_atl.qual.item.tip == 17) then
 			mouse.w,mouse.h = 16,16
	 		mouse:toggle(mouse.esq,236,204)
	 	end
	 	
	 end
	end								
end

function atribuir()
	--o atalho selecionado
	-- ja tem um item?
	-- se ele ja tiver efetuamos
	-- uma troca com o jardim/inv
	if(ls_atl.qual)then
		--exclusivo depot ------------------------------------------------------------
		if(status == 3)then				
	 	if(ls_atl.qual.item)then
	 	 if(atl_para_container(mouse.esq,ls_inv,true)) atl_on_off(true)
			else
   	if(container_para_atl(mouse.esq,ls_inv)) atl_on_off(true)
			end	
			
		--exclusivo jardim rocha  ------------------------------------------------------------
		else
 		--so e possivel por vasos no jardim
			if(ls_atl.qual.item and range(ls_atl.qual.item.tip,5,8))then
	 		if(atl_para_container(mouse.esq,ls_jrd))atl_on_off(true)
			else

	 		--so e possivel guardar vasos sem planta
 			if(ls_jrd.qual and range(ls_jrd.qual.tip,5,8) and not ls_jrd.qual.planta)then
	 			if(container_para_atl(mouse.esq,ls_jrd)) atl_on_off(true)
	 		elseif(ls_atl.qual.item)then
	 		 funcionalidades()
				end
				
			end	
			
		end

	end

end

--[[
	troca de luagres o item do atalho
	atua com algum do inventario que
	for clicado	
]]
function atl_para_container(context,qual_container,permutavel)
	permutavel = permutavel or false	

	if(qual_container.qual and permutavel)then
	 mouse:tip_set(ls_atl.qual.item and 233 or 217,"⬅️","⬆️")		
 else
	 mouse:tip_set(ls_atl.qual.item.cur_s,"⬅️","⬆️")
 end
	 
	if(context)then
		--seta a proprieda onde
		--para o container
		--jardim ou deposito
	 ls_atl.qual.item:foi_onde(qual_container.tipo)

		--se algo do container
		--nao esta sendo selecionado
		--poe na posicao do cursor ajustado
		if((qual_container.qual and not permutavel) or not qual_container.qual)then
			ls_atl.qual.item:mov(stat(32)-11,stat(33)-15)	
	 	--adiciona ao container
			add(qual_container.coisas,ls_atl.qual.item)

 		--esvazia o atalho
 	 ls_atl.qual.item = nil
   
  --se algo do container
		--esta sendo selecionado
		--permuta esse "algo" com
		--o item do atalho
		 qual_container.val  = true
   qual_container.wait = false
   ls_atl.qual = nil
   ls_atl.val = false
   mouse:reset()
 		return false
		else
		 --poe o item do atalho na mesma posicao do item selecionado
			ls_atl.qual.item:mov(qual_container.qual.x,qual_container.qual.y-2)	
			--add o item do atalho no container
			add(qual_container.coisas,ls_atl.qual.item)
 		--remove o item selecionado do container e passa pro atalho
 		ls_atl.qual.item = del(qual_container.coisas,qual_container.qual)
		 ls_atl.qual.item:foi_onde("atalho")
			
			qual_container.val  = true
   qual_container.wait = false
		 return true
		end
	end
	return false
end

function container_para_atl(context,qual_container)
	--se algo do container esta sendo selecionado		

	if(qual_container.qual)then
		if(context)then

			local para_atl        = qual_container.qual
			ls_atl.qual.item      =	del(qual_container.coisas,para_atl)
   ls_atl.qual.item:foi_onde(ls_atl.tipo)
 		ls_atl.qual           = nil
			ls_atl.val            = false
			qual_container.val    = true
	  qual_container.wait   = false

	  return true
		end
	end
	return false
end
-->8
--deposito======================
function des_depot()
 --base
	rect(107,3,119,115,1)
	rect(8,3,107,115,4)
	--pesinhos
	rect(16 ,118,28 ,122,1)
	rect(8  ,118,16 ,122,4)
	rect(107,118,119,122,1)
	rect(99 ,118,107,122,4)
	line(8  ,118,119,118,0)
	
	--pregos frente
	local aux_1,aux_2 = 6,0
 for i=1,3 do
	des_vertices(11,aux_1,94,26,1)
		aux_1 += 53
	end
	--pregos laterais
	aux_1 = 11
	for i=1,4 do
		des_vertices(109,aux_1,9,20,1)
		aux_1 += 26
	end
		
 --prateleiras
	aux_1 = 11
	aux_2 = 32
	for i=1,4 do
		rect(16,aux_1,28,aux_2,1)
		rect(16,aux_1,95,aux_2,4)
		aux_1+= 24
		aux_2+= 24
	end
	
	des_prateleiras(16,32,24)
	des_inv()
end

function des_prateleiras(x_init,y_init,y_esp) 

	aux_y = y_init
	for i in all(ls_prt)do
		i.x  = x_init
	 i.y  = aux_y
  rect(i.x,i.y,i.x+i.w-1,i.y+i.h-1,4)
		aux_y += y_esp
	end
	
end

function init_prat()
	for i=1, 4 do
		criar_obj("prateleira",0,ls_prt)
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
			i.y +=grav
			n_sai_tela(i)	
  else
		end	
	end

end

function def_pos(i)
		i.x = flr(rnd(60)) + 16 
		
		if(i.tip <=4)then
			i.y = 16 
		elseif(i.tip<=8)then
			i.y = 40
		else
			i.y = 64
		end

end
-->8
--jardim =======================
function des_jardim()
 des_inv()
end

function funcionalidades()
	local aux_tipo = ls_atl.qual.item.tip
 --garantido chegar aqui com um item
	if(aux_tipo == 1)then
 	if(mouse.esq)then
	 
			if(#ls_atl.atls == 8)then
			 toggle_disp(1)
			else
				init_atl(2)
 		 def_pos_atls()
			 ls_atl.qual.item = nil
			end
			ls_atl.qual = nil
   atl_on_off(true)
		end
			
 elseif(range(aux_tipo,9,16))then
  mouse.s     = 228
 	if(mouse.esq)then
	  nova_sem    = gerar_part(pat_sem,1,1,3,ls_atl.qual.item, stat(32)+1, stat(33)+13)
			pat_sem.val = true
			ls_atl.qual.item = nil
			ls_atl.qual  = nil
			mouse:reset()

		end
	elseif(aux_tipo == 17)then
		pat_reg.val = true

	end
		
end

function plantar(o_que)
	
	qual_vaso = get_obj_by_col_retg(ls_jrd.coisas,o_que)
	if(qual_vaso and qual_vaso.planta)return
	
	if(qual_vaso)then
		qual_vaso.planta  = o_que.ls_aux.fases
 	qual_vaso.estagio = 3
 	qual_vaso.algo    = 1
  o_que:del()
 	pat_sem.val  = false
 	mouse:reset()
  ls_atl.val = false
 end
 
end

function regar(o_que)

	if(#pat_reg == 0) return 
	qual_vaso = get_obj_by_col_retg(ls_jrd.coisas,o_que)
	
	if(qual_vaso)then
		if(not qual_vaso.colher and qual_vaso.saturac < max_saturac) qual_vaso.saturac += 1
	 o_que:del()
 	if(qual_vaso.saturac >= max_saturac)then
 		qual_vaso:vasar()
			avancar_fase(qual_vaso)
			qual_vaso.saturac=0
		end
		if(qual_vaso.colher)qual_vaso:vasar()
 end
   
end

function avancar_fase(o_que)
 if(not o_que.planta) return
	local inc = 1 --flr(rnd(100))
	o_que.estagio+= inc%2
 if(o_que.estagio >#o_que.planta)then
  o_que.estagio = #o_que.planta
  o_que.colher  = true
 end
end

-->8
--save/load =======================
function save()

	objeto = ls_jrd.coisas[1]
	
end

function save_obj(obj)
	
 if(not obj)return 
	local combinado = 0	 																																																							--estagio											
	local ls_keys   = {"onde", "x", "y","tip","algo"}--planta, capacidade, atalho}
	local ls_crop   = {  0x03,0x7f,0x7f, 0x0f,  0x01,    0x07,       0x07,   0x07}            
	local ls_mov    = {    30,  23,  16,   12,    11,       8,          5,      2}
	local combinado = 0.0
	local crop      = 0
aqui negah
	combinado = (obj.onde & 0x03) << 14
	          | (obj.x    & 0x7f) <<  7
		         | (obj.y    & 0x7f) <<  0
	          | (obj.tip-1& 0x0f) >>> 4
	cu2 = "salvo"
	dset(0,combinado)
end

function load_obj()
	local save = dget(0)
 onde = (save >>> 14) & 0x03
 x    = (save >>>  7) & 0x7f
 y    = (save >>>  0) & 0x7f
 tip  = (save <<   4) & 0x0f
	if(onde == 0) criar_obj("item", tip+1,ls_jrd.coisas,nil, x ,y)
	if(onde == 1) criar_obj("item", tip+1,ls_jrd.coisas,nil, x ,y)

 cu2 = "carregado"
end

function debug_obj(obj)
	
 if(not obj)then
		cu1 = "objeto nulo"
  return
 else
 	cu1 = "selecionado"
 end	
	--keys basicas
	local ls_keys = {"onde", "x", "y","tip","algo"}
	
	--salvar infomacoes bases
	for v,k in pairs(ls_keys)do
		--primeiro cropar os bits extras que possam existir
		print(k..":"..tostr(obj[k]),9)		
	end
	--informaes especificas
	--tem algo
	if(obj.algo == 1)then
  --eh algo que pode ter uma planta
		if(range(obj.tip,3,7))then
 		print("planta: "..obj.planta.tip)
 		print("estagio:"..obj.estagio)
		end
		--eh algo que pode ter uma capacidade
		if(range(obj.tip,1,3))then
 		print("capacidade:"..obj.planta.tip)
		end
	end
end
__gfx__
000000000000000000000000000bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000422200b1b00000000000000000000005577777000000000004224000000000000000000000000000000000000000000000000000000
00666d5000000000000441111bbb1bbb000000000000000000005566666000000000049119400000000066666660000000000000000000000550000000000000
0061111500000000004111111b11111b0000000000000000000000d666d000000000024994209000000611111116600000000000000000000555555555555500
006155d150000000041111111bbb1bbb00000000000000000000055ddd0000000000002112090000006111111161150000000500000000000051111111111500
00d1511d0000000004111999111b1b0044000000000000440000560dd0000000000000999929900000f1111111f1150000005555555000000051551551551500
0051d1500000000000411a19114bbb00414000000000041400006060060000000000041111400000000fffffff11150000055555555500000051111111111500
00051d0d00000000021411a11411111024122244442221420000070000600000000004111140000000d1111111d1150000005555555500000051155155115000
00005000d0000000021141114121112002911111111119200000070bb0600000000041113314000000d1bb1bb1d1150000000500001500000051111111115000
00000000060000000411144411211120021999999999922000007033330d00000004111bb311200000611bbb1161150000000000011100000055555555550000
000000000062440004111111114111200241414141414120000703b33b30d00000411113b1111200006111311161150000001111111000000050000000000000
00000000002002000411111111411120021414141414142000060333bbb0d0000041113111111200006111311161150000001111110000000055555555555000
00000000004020000041111114111200002121212121220000006000000d00000004111111112000006111111161150000000000000000000005500005500000
000000000042000000044444422220000002222222222000000006666dd00000000044444222000000066666666dd00000000000000000000005500005500000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111100000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001444466444410000000000000000000770000000000000
0000000000000000000000000000000000000dddddd00000000dddddddddd0000011111111111100011111111111111000000000000000000777777777777700
000000000000000000000000000000000000d122221d000000d1111111111d000114444664444110019999977999991000000700000000000071111111111700
00000000000000000002444444442000000061222216000000d1122222211d000144444664444410011111177111111000007777777000000071771771771700
00224444444422000021111111111200000016666661000000612222222216000144444664444410011111111111111000077777777700000071111111111700
00211111111112000041414121411400000001111110000000166666666661000144444664444410011122222222111000007777777700000071177177117000
0041414121411400004112141214140000000d1111d00000000d11111111d0000111111661111110011122222222111000000700005700000071111111117000
00411214121414000091214141411900000066dddddd00000066dddddddddd000141416666141410019191777719191000000000055500000077777777770000
00912141414119000009999999999000000d66dddd6dd0000d66d6dd6ddd6dd00141416116141410019191711719191000005555555000000070000000000000
009999999999990000011111111110000001ddddd666100001ddddddd6d666100141441661441410019199177199191000005555550000000077777777777000
0002111111112000000024422222000000011ddddd6110000111dd6ddddd61100141444444441410019199999999191000000000000000000007700007700000
00022444422220000000244222220000000011111111000000111666111111000141444444441410019199999999191000000000000000000007700007700000
0002244442222000000004422220000000000111111000000001116111d110000141111111111410019111111111191000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000144444444444410019999999999991000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000111111111111110011111111111111000000000000000000000000000000000
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
0000000000322300300110030000113333110000000011313311000000000000000b028b33b000000003113333113000000311dddd113000000000b31bb00000
00000000b0b22b0b13133131000bb111111bb000000bb111111bb000000000000000000330bb000000bbb111111bbb0000bbb112211bbb0000000bbb3bbb0000
00bb3000b00bb00bb111111b0000b31bb13b00000000b31bb13b0000000000000000000330000000000bb31bb13bb0000b0bb31bb13bb0b00000003111000000
00b22300033333303b1bb1b30000113bb33300000000113bb33300000000000000000003300000000000113bb33300000000113bb33300000000031313300000
0031130000311300013bb31000000113b110000000000113b110000000000000000000111100000000000113b110000000000113b11000000000000000000000
0000000000000000000000bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000
00000000000b3300000000b22b0bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000090aa00000000
0000000000b03300000bb0322332b0000000000000000000000000b000000000000000000000000000000000000000000000000000000000000099aa99900000
000000000b300000000b230bb232b0000000000000000000000000bb000000000000b0000bbb00000000000000000000000000000000000000009adda9000000
0bb030000033b000000b23b22b2230000000000000000000000000b2b0000000000b0bb033b000000000000000000000000000300000000000aa0ddd0aa00000
000b0000000b00000000323223230000000000bbb0000000000000b22b00b0000000000b3000000000000000000000000000000b30000000000a90009aaa0000
0000b0000000b0000000032222300000000000b22b000000000b0032230bb0000000003bb30000000000000000000000000000b000f0f0000000a909a9000000
00031130000311300000311111130000000000b22b0bb000000bb0122232b0000000092332900000000000b003bb000000000b000f0f0f00000999aa99000000
00000000000000000000000300000000000bb0322332b000000b2312b232b0000000a292992a000000000b00333bb00000000300f07070f00000001a190bb000
0000000000000000000000b09a000000000b23222232b000000b232b2b323000000092a2aa29000000000300b3b3b300000bb3000f070f00000bb00110bb3300
000000000000000000000b09a9a00000000b232bbb323000000b232b2b3230000033929299293300000bb300bb300300000033006060606000bbbb3013330030
00000000000000000000030a9a900000000b23b22b223000000322b22b223000000322929922300000003bb00bb0300000000bb00606060000003bb313000000
0000000000000000000bb300a90000000003223223223000000322322322300000bbb222922bbb0000000b000033000000000b00006060000000000310000000
000000000000000000000bb00000000000003232232300000000323223230000000bb32bb23bb000000030b000000000000030b0000000000000003111000000
00000000000000000000000b00000000000003222230000000000322223000000000113bb33300000000000b000000000000000b000000000000031313300000
000000000000000000000311113000000000311111130000000031111113000000000113b1100000000003111130000000000311113000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb00b300000
0000000000000000000000000000000000000000000888000000000000000000000000000000000000003330000000000000b0000bbb00000000bbbb03330000
000000000000000000000000000000000000000088822280000000000000000000000000000000000000033000000000000b0bb033b000000000000b30000000
000000000000000000000000000000000008000082288280000000000000000000000033033000000000000b300000000000000b300000000000088338800000
00000000000000000000000000030000008280000822280000000000000000000000000b30000000000000b000a0a0000000003bb30000000000878888780000
000000000000000000000000003230000b424b000b888b0000000000000000000000003bb300000000b00b000a0a0a0000000a9339a000000000887777880000
0000000000000000000300000bb2bb0000bb300000bb30000000000000000000000003133130000000bb0300a07070a0000079a9aa9700000030288888820300
00000000000000000bb2bb0000bb3000000300000003000000000000000000000000b131331b0000000bb3000a070a000000a979779a00000033122222213300
000000000bb0bb0000bb3000000300000bb300000bb300000000000000000000000031b1bb13000000003300909090900033a9a9aa9a330000b3112222113b00
0000000000bb3000000300000bb30000b0033300b00333000000000000000000003331313313330000000bb009090900000399a9aa99300000bbb11b111bbb00
0bb0bb00000300000bb30000b003330000330030003300300000000000000000000311313311300000000bb00090900000bbb999a99bbb00000bb31bb13bb000
00b3300000b3000000033300003300300003b0000003b000000000000000000000bbb111311bbb00003330b000000000000bb39bb93bb0000000113bb3330000
0003000000033000003300000003b00000330b0000330b000000000000000000000bb31bb13bb0000003300b000000000000113bb33300000000011111100000
00030000000300000003000000330000000300000003000000000000000000000000113bb3330000000003333330000000000113b11000000000000000000000
001111000011110000111100001111000011110000111100000000000000000000000113b1100000000000000000000000000000000000000000000000000000
55550000555500005500000055550000000000000000000000000000000030000000000000000000000000000b03300000000000000000000000000000000000
0550000055050000550000005505000000000000009000090bbb0b3000bb3b300090a00000000bbb0088828000b0077000000000000000000000000000000000
0550000055050000550000005555000000bb03300009b039b003b3000003b3000099aa990000b0b3002000200b00706600000000000000000000000000000000
05500000555500005555000055050000008b3320000b303300943490007c3c6000a24290000b0b03000288000b00600600000000000000000000000000000000
0000000000000000000000000000000008888882090000000a4949490cc766dd0aa424aa0bb0b030000080000300066000000000000000000000000000000000
0000000000000000000000000000000008e8888200930bb30a4a4a490cccccdd009242a00b0b030000bbb3300030000000000000000000000000000000000000
0000000000000000000000000000000008ee882800330bb3094949490cdcdddd099aa9900300b0000003b0000003300000650006666607000000000000000000
0000000000000000000000000000000000882280000003330094949000cdcdd00000a0900333b000000033000000000006570066555760700000000000000000
55550000555500005555000055550000811111110ddd000000444400000000000044440000111100000000000000000005750076111770600000000000000000
5505000055550000550000005550000017777771d776d00004111140000000000004200e111bb111000000000000000000056057777750600000000000000000
5555000055050000555000005500000016111710d7dd6d00419911420000000000eeeee01bbbbbb1000000000000000000005655555550500000000000000000
550000005505000055000000555500001611710056d7d50044114412400000040041120e01bbbb10000000000000000000000555675655000000000000000000
0000000000000000000000000000000016161610056d70004144121224242424041131201c1bb1c1000000000000000000000055675650000000000000000000
0000000000000000000000000000000016616671005506444111141222424242041311201c1111c1000000000000000000000005665600000000000000000000
00000000000000000000000000000000161017710000020441114112242424220411112001cccc10000000000000000000000000000000000000000000000000
00000000000000000000000000000000110001110000042204442220022222200044220000111100000000000000000000000000000000000000000000000000
55550000555000005505000055550000011111000dddd0000000000000bbbb001111111111111111000000000000000000000000000000000000000000000000
5505000050550000550500000550000016777611057650000000000000b11b00188118811bbbbcc1000000000000000000000000000000000000000000000000
5550000055050000555500000550000077777777576dd50044444222bbb11bbb188828811b111cc1000000000000000000000000000000000000000000000000
550500005555000055550000555500006776777655d7bdd041111112b111111b11888211bbb11181000000000000000000000000077700000000000000000000
0000000000000000000000000000000067611766005b7bbd44444222b111111b112888111b111888000000000000000000000000700060000000000000000000
00000000000000000000000000000000761766110053bbbd01111110bbb11bbb1882888114411181000000000000000000000006677005000000000000000000
0000000000000000000000000000000017171100000533350211112000b11b001881188114488881000000000000000000000065567505000000000000000000
0000000000000000000000000000000001110000000555550244422000bbbb001111111111111111000000000000000000000651167550000000000000000000
55550000500500005505000055550000777000007707000077070000000000000000000000dddd00000000000000000000000651675565000000000000000000
5550000055050000550500005500000070770000770700007707000000000000000006600d111dd0000000000000000000000677757556000000000000000000
0555000055550000555500005500000077070000777700007777000000000000d600600dd6666d15000000000000000000000065566750000000000000000000
555500005555000005500000555500007777000077770000077000000000000066ddd00dd1111d15000000000000000000760005556600000000000000000000
00000000000000000000000000000000000000000000000000000000000000000d61160dd1bb1d15000000000000000000675555555000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000d166160d1bb1d15000000000000000000565000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000d111160d1111d15000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000dddd000ddddd50000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888777777888eeeeee888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88ee88eee88ee888ee88ee888ee88ee8e8ee88ee888ee88778777788ee888ee88888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8eeee8eee8eeeee8ee8eeeee8ee8eee8e8ee8eee8eeee8777877778eeeee8ee88888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8eeee8eee8eee888ee8eeee88ee8eee888ee8eee888ee8777888778eeeee8ee88e8e888ff888ff888222222888888222888228882888822288888
888eee8e8ee8eeee8eee8eee8eeee8eeeee8ee8eeeee8ee8eeeee8ee8777878778eeeee8ee88888888ff888ff888822228888228222888882282888222288888
888eee888ee8eee888ee8eee888ee8eee888ee8eeeee8ee8eee888ee8777888778eeeee8ee888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8777777778eeeeeeee888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ddd1ddd1dd11d1d11111dd11ddd11111ddd1ddd1ddd1d111d1d11dd1111111111111111111111111111111111111111111111111111111111111111
111111111ddd1d111d1d1d1d11111d1d1d1111111d1d11d11d1d1d111d1d1d1d1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd
1ddd1ddd1d1d1dd11d1d1d1d11111d1d1dd111111ddd11d11ddd1d111ddd1d1d1111111111111111111111111111111111111111111111111111111111111111
111111111d1d1d111d1d1d1d11111d1d1d1111111d1d11d11d1d1d111d1d1d1d1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd
111111111d1d1ddd1d1d11dd1ddd1ddd1ddd1ddd1d1d11d11d1d1ddd1d1d1dd11111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116661661166616661111166616661611117111611616166616611666116611661111166616661666166611661171
1e111e1e1e1e1e1111e111e11e1e1e1e111111611616116111611111161611611611171116161616161616161161161616111111161616161616161116111117
1ee11e1e1e1e1e1111e111e11e1e1e1e111111611616116111611111166611611611171116161616166616161161161616661111166616661661166116661117
1e111e1e1e1e1e1111e111e11e1e1e1e111111611616116111611111161611611611171116611616161616161161161611161111161116161616161111161117
1e1111ee1e1e11ee11e11eee1ee11e1e111116661616166611611666161611611666117111661166161616161161166116611666161116161616166616611171
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111161161616661661166611661166111111111111116116161666166116661166116611111666166616661666116611111771111111111cc1111111111111
111116161616161616161161161616111111177711111616161616161616116116161611111116161616161616117111111117711111111c11c1111111111111
1111161616161666161611611616166611111111111116161616166616161161161616661111166616661661166177161111117711111ccc11c1111111111111
1111166116161616161611611616111611111777111116611616161616161161161611161111161116161616161177711111171711111c1111c1111111111111
11111166116616161616116116611661111111111111116611661616161611611661166116661611161616161661777711111777111111111ccc111111111111
11111111111188888111111111111111111111111111111111111111111111111111111111111111111111111111771111111111111111111111111111111111
11111166166688888111111111111111111111111111111111111111111111111111111111111111111111111111117111111111111111111111111111111111
11111611111688888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611166688888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611161188888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111166166688888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee1171116116161666166116661166116617111ccc1171111111611616166616611666116611661111111111111ccc111111111111111111111111
111111e11e111711161616161616161611611616161111711c1c1117111116161616161616161161161616111111177711111c1c111111111111111111111111
111111e11ee11711161616161666161611611616166611171ccc1117111116161616166616161161161616661111111111111ccc111111111111111111111111
111111e11e111711166116161616161611611616111611711c1c1117111116611616161616161161161611161111177711111c1c111111111111111111111111
11111eee1e111171116611661616161611611661166117111ccc1171111111661166161616161161166116611111111111111ccc111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee1171116116161666166116661166116611171ccc1171111111611616166616611666116611661111111111111ccc111111111111111111111111
111111e11e11171116161616161616161161161616111171111c111711111616161616161616116116161611111117771111111c111111111111111111111111
111111e11ee11711161616161666161611611616166617111ccc1117111116161616166616161161161616661111111111111ccc111111111111111111111111
111111e11e111711166116161616161611611616111611711c111117111116611616161616161161161611161111177711111c11111111111111111111111111
11111eee1e111171116611661616161611611661166111171ccc1171111111661166161616161161166116611111111111111ccc111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee11ee1eee1111166611111cc11111116116161666166116661166116611111666166616661666116611111ee111ee1111111111111111111111111111
11111e111e1e1e1e11111161177711c11111161616161616161611611616161111111616161616161611161111111e1e1e1e1111111111111111111111111111
11111ee11e1e1ee111111161111111c11111161616161666161611611616166611111666166616611661166611111e1e1e1e1111111111111111111111111111
11111e111e1e1e1e11111161177711c11171166116161616161611611616111611111611161616161611111611111e1e1e1e1111111111111111111111111111
11111e111ee11e1e1111166611111ccc1711116611661616161611611661166116661611161616161666166111111eee1ee11111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116611666161611111666166616111111111111111111111111111111111111661666166616661666111111661666166611711c1c1ccc11cc1ccc1ccc
1111111116161611161611111616116116111111111111111111111111111777111116111616116116161616111116161616116117111c1c1c111c111c1c1c1c
11111111161616611616111116661161161111111111111111111111111111111111161116611161166616611111161616611161171111111cc11ccc1ccc1ccc
11111111161616111666111116161161161111111111111111111111111117771111161116161161161616161111161616161161171111111c11111c1c111c1c
11111111161616661666166616161161166611111111111111111111111111111111116616161666161616161666166116661661117111111ccc1cc11c111c1c
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111661166616161111166616661611111116661666166616661111111111111cc11ccc1c11111111111111111111111111111111111111111111111111
111111111616161116161111161611611611111111611161161116661111177711111c1c11c11c11111111111111111111111111111111111111111111111111
111111111616166116161111166611611611111111611161166116161111111111111c1c11c11c11111111111111111111111111111111111111111111111111
111111111616161116661111161611611611111111611161161116161111177711111c1c11c11c11111111111111111111111111111111111111111111111111
111111111616166616661666161611611666117116661161166616161111111111111c1c1ccc1ccc111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111661166616161111166616661611111111661166166616611111111111111cc111111111111111111111111111111111111111111111111111111111
1111111116161611161611111616116116111111161116161616116111111777111111c111111111111111111111111111111111111111111111111111111111
1111111116161661161611111666116116111111161116161661116111111111111111c111111111111111111111111111111111111111111111111111111111
1111111116161611166611111616116116111111161116161616116111111777111111c111111111111111111111111111111111111111111111111111111111
111111111616166616661666161611611666117111661661161616661111111111111ccc11111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111661166616161111166616661611111111661166166616661111111111111ccc11111111111111111111111111111111111111111111111111111111
11111111161616111616111116161161161111111611161616161116111117771111111c11111111111111111111111111111111111111111111111111111111
11111111161616611616111116661161161111111611161616611666111111111111111c11111111111111111111111111111111111111111111111111111111
11111111161616111666111116161161161111111611161616161611111117771111111c11111111111111111111111111111111111111111111111111111111
11111111161616661666166616161161166611711166166116161666111111111111111c11111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111661166616161111166616661611111111661166166616661111111111111cc111111111111111111111111111111111111111111111111111111111
1111111116161611161611111616116116111111161116161616111611111777111111c111111111111111111111111111111111111111111111111111111111
1111111116161661161611111666116116111111161116161661116611111111111111c111111111111111111111111111111111111111111111111111111111
1111111116161611166611111616116116111111161116161616111611111777111111c111111111111111111111111111111111111111111111111111111111
111111111616166616661666161611611666117111661661161616661111111111111ccc11111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166116661616111116661666161111111666166111111111111111111111171716111166111116661666161111111666166616111166111111111111
11111111161616111616111116161161161111111161161611111111111117771111177716111611111116161161161111111616116116111611111111111111
11111111161616611616111116661161161111111161161611111111111111111111171716111666111116661161161111111666116116111666111111111111
11111111161616111666111116161161161111111161161611111111111117771111177716111116111116161161161111111616116116111116111111111111
11111111161616661666166616161161166611711666166611111111111111111111171716661661166616161161166611711616116116661661111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111661166616161111166616661611111116661111111111111111111111111ccc11111ccc111111111111111111111111111111111111111111111111
111111111616161116161111161611611611111116161111111111111111177711111c1c11111c11111111111111111111111111111111111111111111111111
111111111616166116161111166611611611111116611111111111111111111111111ccc11111ccc111111111111111111111111111111111111111111111111
111111111616161116661111161611611611111116161111111111111111177711111c1c1111111c111111111111111111111111111111111111111111111111
111111111616166616661666161611611666117116161111111111111111111111111ccc11c11ccc111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888828288828222822282228888888888888888888888888888888888888888888882888222822282288882822282288222822288866688
82888828828282888888828288288882888288828888888888888888888888888888888888888888888882888882888288288828828288288282888288888888
82888828828282288888822288288222822288228888888888888888888888888888888888888888888882228882888288288828822288288222822288822288
82888828828282888888888288288288828888828888888888888888888888888888888888888888888882828882888288288828828288288882828888888888
82228222828282228888888282888222822282228888888888888888888888888888888888888888888882228882888282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__sfx__
00070000040500a05011050260501b0500705014050210502a050270501e050130500605005050150501e050160500c0500a0500e05014050200502705028050210500f0500e050140501b050230502a05027050
00100000000001f6501e6501e6501d6501d6501d6501d6501d6501e6501f650216502265023650000002565026650276502765027650246501f650136501265012650126501565018650166501e6500000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000023650236502365025650000002765000000000002a650000002c650000002f6502f6502c65000000276500000000000226501e6501d6501c6501c6501d6501f650216500000026650286502565000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000e1500e1500e15017650221501c1501815020250202501e250141501d2501b2501a2500c1500c1500d1500e15012150171501d1502115025150191500715007150091501c65024650000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001a6501a6501a6501a6501b6501c6501d6501d650000001a65017650146501365013650000001365000000146500000015650000000000000000156500000000000000001565000000000001565015650
