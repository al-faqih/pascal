
uses Allegro5, Al5image;

Const
  FPS = 60;
  frame_delay = 10;
  screen_h = 800;
  screen_w = 600;
type 
  projectiles = (Bullet, Rocket);
  bu = array [1..5] of record 
                         ID : projectiles;
                         live : Boolean;
                         x, y  : real;
                         rad, speed : real;
                         Bulletimage, Rocketimage : ALLEGRO_BITMAPptr;
                         maxBullets : byte;
                       end;
  Ship = record
           s, x, y, rad : real;
           deg          : integer;
         end;
Var
  Display       : ALLEGRO_DISPLAYptr;
  redfighter,
  SpaceWall     : ALLEGRO_BITMAPptr;  
  cond          : boolean; 
  timer         : ALLEGRO_TIMERptr;
  event_queue   : ALLEGRO_EVENT_QUEUEptr;
  ev            : ALLEGRO_EVENT;
  i : byte;
  Up, Down, 
  redraw, Turbo  : Boolean;
  Bullets    : bu; 
  TShip : Ship;

procedure Initprojectiles(var Bullets : bu);
Var
  i : byte;
begin
  Bullets[i]
  for i:=1 to 5 do begin
    Bullets[i].ID := Bullet;
    Bullets[i].Bulletimage := al_load_bitmap('bullet1.png');
    Bullets[i].live := False;
    Bullets[i].speed := 10;
  end;
end;

procedure Fireprojectile(var Bullets : bu; TShip : Ship);
var 
  i : byte;
begin
  for i:=1 to Bullets.maxBullets do 
    if not(Bullets[i].live) then begin
      Bullets[i].rad := TShip.rad ;
      Bullets[i].live := True;
      Bullets[i].x := TShip.x;
      Bullets[i].y := TShip.y;
      break;
    end;
end;

procedure Updateprojectile(var Bullets : bu) ;
var 
  i : byte;
begin
  for i:=1 to 5 do 
    if Bullets[i].live then begin
      Bullets[i].x += trunc(cos(Bullets[i].rad)*Bullets[i].speed);
      Bullets[i].y += trunc(sin(Bullets[i].rad)*Bullets[i].speed);
      al_draw_rotated_bitmap(Bullets[i].Bulletimage, 16 / 2, 16 / 2, Bullets[i].x, Bullets[i].y, Bullets[i].rad, 0); 
      
    end;
end;


BEGIN
  TShip.s := 1;
  TShip.x := 200;
  TShip.y := 100;
  TShip.x := 100;
  cond := True;
  al_init();
  al_init_image_addon();
  al_install_keyboard(); 
  Initprojectiles(Bullets);
  Display := al_create_display(screen_h, screen_w);
  timer := al_create_timer(1.0/FPS);
  event_queue := al_create_event_queue();
  al_register_event_source(event_queue, al_get_display_event_source(Display));
  al_register_event_source(event_queue, al_get_timer_event_source(timer));
  al_register_event_source(event_queue, al_get_keyboard_event_source());
  al_start_timer(timer);


  redfighter := al_load_bitmap('redfighter.png');
  SpaceWall := al_load_bitmap('galaxy.jpg');
  while cond do begin
    al_wait_for_event(event_queue, ev);

    if (ev._type = ALLEGRO_EVENT_DISPLAY_CLOSE) then cond := False
    else if (ev._type = ALLEGRO_EVENT_KEY_DOWN) then 
      case ev.keyboard.keycode of 
        AlLEGRO_KEY_UP    : Up    := True;
        ALLEGRO_KEY_DOWN  : Down  := True;
        ALLEGRO_KEY_SPACE : Turbo := True;
        ALLEGRO_KEY_W     : Fireprojectile(Bullets, TShip); 
      end
    else if (ev._type = ALLEGRO_EVENT_KEY_UP) then 
       case ev.keyboard.keycode of 
        AlLEGRO_KEY_UP    : Up    := False;
        ALLEGRO_KEY_DOWN  : Down  := False;
        ALLEGRO_KEY_SPACE : Turbo := False; 
       end
    else if (ev._type = ALLEGRO_EVENT_TIMER) then begin 
      if Turbo then TShip.s += 0.1  
      else if TShip.s > 0 then TShip.s -= 0.1;
      if Up then TShip.deg -= 3 
      else if Down then TShip.deg += 3;
      TShip.rad := TShip.deg * pi /180;
     
      TShip.x += trunc(cos(TShip.rad)*TShip.s);
      TShip.y += trunc(sin(TShip.rad)*TShip.s);
      {object redirection} 
     if (screen_h+68 < TShip.x) then TShip.x := -68
     else if (-76 > TShip.y) then TShip.y := screen_w+76
     else if (screen_w+76 < TShip.y) then TShip.y := -76
     else if (-68 > TShip.x) then TShip.x := screen_h+68; 
     redraw := True;
     if redraw and al_is_event_queue_empty(event_queue) then begin
       al_draw_bitmap(SpaceWall, 0, 0, 0);
       {al_clear_to_color(al_map_rgb(0, 12, 11));}
       { Drawing the ship :3 }
       al_draw_rotated_bitmap(redfighter, 68 / 2, 76 / 2, TShip.x , TShip.y, TShip.rad  , 0);
       Updateprojectile(Bullets);
     al_flip_display();
     redraw := False;
     end; 
    end;

  end;
  al_destroy_bitmap(redfighter);
  al_destroy_event_queue(event_queue); 
  al_destroy_timer(timer);  
  al_destroy_display(Display); 
END.


