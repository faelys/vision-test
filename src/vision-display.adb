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

with Ada.Unchecked_Conversion;
with Interfaces.C.Strings;
with XCB;

package body Vision.Display is

   function Scaled_Rectangle
     (Origin : XCB.Point_Type;
      X, Y : Interfaces.Integer_16;
      W, H : Interfaces.Unsigned_16;
      Scale : Interfaces.Unsigned_16)
     return XCB.Rectangle_Type;

   function Snellen_E
     (Top_Left : in XCB.Point_Type;
      Gap_Size : in Interfaces.Unsigned_16;
      Direction : in Directions.Enum)
     return XCB.Rectangle_Array_Type;


   protected Drawer is
      procedure Initialize
        (C : in XCB.Connection_Access_Type;
         W : in XCB.Window_Id_Type;
         GC : in XCB.Gcontext_Id_Type;
         Black, White : in Interfaces.Unsigned_32);

      procedure Update_Size (Width, Height : in Interfaces.Unsigned_16);

      procedure Update
        (New_Gap_Size : in Interfaces.Unsigned_16;
         New_Direction : in Directions.Enum);

      entry Redraw;
   private
      Initialized : Boolean := False;
      Sized : Boolean := False;
      Connection : XCB.Connection_Access_Type;
      Window : XCB.Window_Id_Type;
      Context : XCB.Gcontext_Id_Type;

      Whole_Window : XCB.Rectangle_Array_Type (0 .. 0)
        := (0 => (X => 0, Y => 0, Width => 150, Height => 150));
      Gap_Size : Interfaces.Unsigned_16 := 2;
      Direction : Directions.Enum := Directions.West;
      Color_Black, Color_White : Interfaces.Unsigned_32;
   end Drawer;


   task X_Event_Loop is
      entry Start;
      entry Ending;
   end X_Event_Loop;



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


   function Snellen_E
     (Top_Left : in XCB.Point_Type;
      Gap_Size : in Interfaces.Unsigned_16;
      Direction : in Directions.Enum)
     return XCB.Rectangle_Array_Type is
   begin
      case Direction is
         when Directions.North =>
            return
              (0 => Scaled_Rectangle (Top_Left, 0, 0, 5, 1, Gap_Size),
               1 => Scaled_Rectangle (Top_Left, 0, 1, 1, 4, Gap_Size),
               2 => Scaled_Rectangle (Top_Left, 4, 1, 1, 4, Gap_Size),
               3 => Scaled_Rectangle (Top_Left, 2, 1, 1, 3, Gap_Size));

         when Directions.South =>
            return
              (0 => Scaled_Rectangle (Top_Left, 0, 4, 5, 1, Gap_Size),
               1 => Scaled_Rectangle (Top_Left, 0, 0, 1, 4, Gap_Size),
               2 => Scaled_Rectangle (Top_Left, 4, 0, 1, 4, Gap_Size),
               3 => Scaled_Rectangle (Top_Left, 2, 1, 1, 3, Gap_Size));

         when Directions.West =>
            return
              (0 => Scaled_Rectangle (Top_Left, 0, 0, 1, 5, Gap_Size),
               1 => Scaled_Rectangle (Top_Left, 1, 0, 4, 1, Gap_Size),
               2 => Scaled_Rectangle (Top_Left, 1, 4, 4, 1, Gap_Size),
               3 => Scaled_Rectangle (Top_Left, 1, 2, 3, 1, Gap_Size));

         when Directions.East =>
            return
              (0 => Scaled_Rectangle (Top_Left, 4, 0, 1, 5, Gap_Size),
               1 => Scaled_Rectangle (Top_Left, 0, 0, 4, 1, Gap_Size),
               2 => Scaled_Rectangle (Top_Left, 0, 4, 4, 1, Gap_Size),
               3 => Scaled_Rectangle (Top_Left, 1, 2, 3, 1, Gap_Size));
      end case;
   end Snellen_E;



   protected body Drawer is
      procedure Initialize
        (C : in XCB.Connection_Access_Type;
         W : in XCB.Window_Id_Type;
         GC : in XCB.Gcontext_Id_Type;
         Black, White : in Interfaces.Unsigned_32) is
      begin
         Connection := C;
         Window := W;
         Context := GC;
         Color_Black := Black;
         Color_White := White;
         Initialized := True;
      end Initialize;


      procedure Update_Size (Width, Height : in Interfaces.Unsigned_16) is
      begin
         Whole_Window (0).Width := Width;
         Whole_Window (0).Height := Height;
         Sized := True;
      end Update_Size;


      procedure Update
        (New_Gap_Size : in Interfaces.Unsigned_16;
         New_Direction : in Directions.Enum) is
      begin
         Gap_Size := New_Gap_Size;
         Direction := New_Direction;
      end Update;


      entry Redraw when Initialized and Sized is
         use type Interfaces.Unsigned_16;

         Top_Left : constant XCB.Point_Type
           := (X => Interfaces.Integer_16
                  ((Whole_Window (0).Width - Gap_Size * 5) / 2),
               Y => Interfaces.Integer_16
                  ((Whole_Window (0).Height - Gap_Size * 5) / 2));

         Rectangles : constant XCB.Rectangle_Array_Type
           := Snellen_E (Top_Left, Gap_Size, Direction);

         Unused_Cookie : XCB.Void_Cookie_Type;
         pragma Unreferenced (Unused_Cookie);

         Unused_Int : Interfaces.C.int;
         pragma Unreferenced (Unused_Int);
      begin
         Unused_Cookie := XCB.Change_Gc
           (C => Connection,
            Gc => Context,
            Value_Mask => Interfaces.Unsigned_32 (XCB.XCB_GC_FOREGROUND),
            Value_List => (0 => Color_White));

         Unused_Cookie := XCB.Poly_Fill_Rectangle
           (C => Connection,
            Drawable => Window,
            Gc => Context,
            Rectangles_Length => Whole_Window'Length,
            Rectangles => Whole_Window);

         Unused_Cookie := XCB.Change_Gc
           (C => Connection,
            Gc => Context,
            Value_Mask => Interfaces.Unsigned_32 (XCB.XCB_GC_FOREGROUND),
            Value_List => (0 => Color_Black));

         Unused_Cookie := XCB.Poly_Fill_Rectangle
           (C => Connection,
            Drawable => Window,
            Gc => Context,
            Rectangles_Length => Rectangles'Length,
            Rectangles => Rectangles);

         Unused_Int := XCB.Flush (Connection);
      end Redraw;
   end Drawer;



   task body X_Event_Loop is
      Connection : constant XCB.Connection_Access_Type
        := XCB.Connect (Interfaces.C.Strings.Null_Ptr);
      Screen : constant XCB.Screen_Access_Type
        := XCB.Setup_Roots_Iterator (XCB.Get_Setup (Connection)).Data;
      Window : constant XCB.Window_Id_Type
        := XCB.Generate_Id (Connection);
      Context : constant XCB.Gcontext_Id_Type
        := XCB.Generate_Id (Connection);

      pragma Warnings (Off);
      function To_Configure_Notify_Event
        is new Ada.Unchecked_Conversion
           (Source => XCB.Generic_Event_Access_Type,
            Target => XCB.Configure_Notify_Event_Access_Type);
      pragma Warnings (On);

      Unused_Cookie : XCB.Void_Cookie_Type;
      pragma Unreferenced (Unused_Cookie);

      Unused_Int : Interfaces.C.int;
      pragma Unreferenced (Unused_Int);
   begin
      accept Start;

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
           := XCB.XCB_EVENT_MASK_EXPOSURE or XCB.XCB_EVENT_MASK_KEY_PRESS
              or XCB.XCB_EVENT_MASK_STRUCTURE_NOTIFY;
         Mask : constant XCB.Cw_Type
           := XCB.XCB_CW_BACK_PIXEL or XCB.XCB_CW_EVENT_MASK;
         List : aliased constant XCB.Value_List_Array
           := (0 => Screen.White_Pixel,
               1 => Interfaces.Unsigned_32 (Events));
         Size : constant Interfaces.Unsigned_16
           := Interfaces.Unsigned_16 (Maximum_Size * 6);
      begin
         Unused_Cookie := XCB.Create_Window
           (C => Connection,
            Depth => 0,
            Wid => Window,
            Parent => Screen.Root,
            X => 0,
            Y => 0,
            Width => Size,
            Height => Size,
            Border_Width => 1,
            Class => XCB.XCB_WINDOW_CLASS_INPUT_OUTPUT,
            Visual => Screen.Root_Visual,
            Value_Mask => Interfaces.Unsigned_32 (Mask),
            Value_List => List);
      end Create_Window;

      Drawer.Initialize (Connection, Window, Context,
        Screen.Black_Pixel, Screen.White_Pixel);

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
                  Drawer.Redraw;

               when XCB.XCB_CONFIGURE_NOTIFY =>
                  declare
                     Full_Event
                       : constant XCB.Configure_Notify_Event_Access_Type
                       := To_Configure_Notify_Event (Event);
                  begin
                     Drawer.Update_Size (Full_Event.Width, Full_Event.Height);
                  end;

               when others =>
                  null;
            end case;

            XCB.Free (Event);
            exit Main_Loop when Exiting;
         end;
      end loop Main_Loop;

      accept Ending;
   end X_Event_Loop;



   procedure Start is
   begin
      X_Event_Loop.Start;
   end Start;


   procedure Stop is
   begin
      X_Event_Loop.Ending;
   end Stop;


   procedure Update (Size : in Detail_Size; Direction : in Directions.Enum) is
   begin
      Drawer.Update (Interfaces.Unsigned_16 (Size), Direction);
      Drawer.Redraw;
   end Update;

end Vision.Display;
