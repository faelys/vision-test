------------------------------------------------------------------------------
-- Copyright (c) 2016, Natacha Porté                                        --
--                                                                          --
-- Permission to use, copy, modify, and distribute this software for any    --
-- purpose with or without fee is hereby granted, provided that the above   --
-- copyright notice and this permission notice appear in all copies.        --
--                                                                          --
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES --
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF         --
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR  --
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES   --
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN    --
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF  --
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.           --
------------------------------------------------------------------------------

with Interfaces.C.Strings;
with XCB;


procedure Vision.Main is
   Connection : constant XCB.Connection_Access_Type
     := XCB.Connect (Interfaces.C.Strings.Null_Ptr);
   Screen : constant XCB.Screen_Access_Type
     := XCB.Setup_Roots_Iterator (XCB.Get_Setup (Connection)).Data;
   Window : constant XCB.Window_Id_Type
     := XCB.Generate_Id (Connection);
   Context : constant XCB.Gcontext_Id_Type
     := XCB.Generate_Id (Connection);

   Unused_Cookie : XCB.Void_Cookie_Type;
   pragma Unreferenced (Unused_Cookie);

   Unused_Int : Interfaces.C.int;
   pragma Unreferenced (Unused_Int);


   function Scaled_Rectangle
     (Origin : XCB.Point_Type;
      X, Y : Interfaces.Integer_16;
      W, H : Interfaces.Unsigned_16;
      Scale : Interfaces.Unsigned_16)
     return XCB.Rectangle_Type;

   procedure Snellen_E
     (Top_Left : in XCB.Point_Type;
      Gap_Size : in Interfaces.Unsigned_16);


   function Scaled_Rectangle
     (Origin : XCB.Point_Type;
      X, Y : Interfaces.Integer_16;
      W, H : Interfaces.Unsigned_16;
      Scale : Interfaces.Unsigned_16)
     return XCB.Rectangle_Type
   is
      use type Interfaces.Integer_16;
      use type Interfaces.Unsigned_16;
      S_Scale : constant Interfaces.Integer_16
        := Interfaces.Integer_16 (Scale);
   begin
      return (X => Origin.X + S_Scale * X,
              Y => Origin.Y + S_Scale * Y,
              Width => Scale * W,
              Height => Scale * H);
   end Scaled_Rectangle;


   procedure Snellen_E
     (Top_Left : in XCB.Point_Type;
      Gap_Size : in Interfaces.Unsigned_16)
   is
      Rectangles : constant XCB.Rectangle_Array_Type
        := (0 => Scaled_Rectangle (Top_Left, 0, 0, 1, 5, Gap_Size),
            1 => Scaled_Rectangle (Top_Left, 1, 0, 4, 1, Gap_Size),
            2 => Scaled_Rectangle (Top_Left, 1, 4, 4, 1, Gap_Size),
            3 => Scaled_Rectangle (Top_Left, 1, 2, 3, 1, Gap_Size));
   begin
      Unused_Cookie := XCB.Poly_Fill_Rectangle
        (C => Connection,
         Drawable => Window,
         Gc => Context,
         Rectangles_Length => Rectangles'Length,
         Rectangles => Rectangles);
   end Snellen_E;

begin
   Create_Graphic_Context :
   declare
      use type XCB.Gc_Type;
      Mask : constant XCB.Gc_Type
        := XCB.XCB_GC_FOREGROUND
        or XCB.XCB_GC_BACKGROUND
        or XCB.XCB_GC_GRAPHICS_EXPOSURES;
      List : aliased constant XCB.Value_List_Array
        := (0 => Screen.Black_Pixel,
            1 => Screen.White_Pixel,
            2 => 0);
   begin
      Unused_Cookie := XCB.Create_Gc
        (C => Connection,
         Cid => Context,
         Drawable => Screen.Root,
         Value_Mask => Interfaces.Unsigned_32 (Mask),
         Value_List => List);
   end Create_Graphic_Context;

   Create_Window :
   declare
      use type XCB.Cw_Type;
      use type XCB.Event_Mask_Type;
      Events : constant XCB.Event_Mask_Type
        := XCB.XCB_EVENT_MASK_EXPOSURE or XCB.XCB_EVENT_MASK_KEY_PRESS;
      Mask : constant XCB.Cw_Type
        := XCB.XCB_CW_BACK_PIXEL or XCB.XCB_CW_EVENT_MASK;
      List : aliased constant XCB.Value_List_Array
        := (0 => Screen.White_Pixel,
            1 => Interfaces.Unsigned_32 (Events));
   begin
      Unused_Cookie := XCB.Create_Window
        (C => Connection,
         Depth => 0,
         Wid => Window,
         Parent => Screen.Root,
         X => 0,
         Y => 0,
         Width => 150,
         Height => 150,
         Border_Width => 1,
         Class => XCB.XCB_WINDOW_CLASS_INPUT_OUTPUT,
         Visual => Screen.Root_Visual,
         Value_Mask => Interfaces.Unsigned_32 (Mask),
         Value_List => List);
   end Create_Window;

   Unused_Cookie := XCB.Map_Window (Connection, Window);
   Unused_Int := XCB.Flush (Connection);

   Main_Loop :
   loop
      declare
         use type XCB.Generic_Event_Access_Type;
         Event : XCB.Generic_Event_Access_Type
           := XCB.Wait_For_Event (Connection);
         Exiting : Boolean := False;
      begin
         exit Main_Loop when Event = null;

         case Event.Response_Kind is
            when XCB.XCB_KEY_PRESS =>
               Exiting := True;

            when XCB.XCB_EXPOSE =>
               Snellen_E ((15, 15), 24);
               Unused_Int := XCB.Flush (Connection);

            when others =>
               null;
         end case;

         XCB.Free (Event);
         exit Main_Loop when Exiting;
      end;
   end loop Main_Loop;

end Vision.Main;
