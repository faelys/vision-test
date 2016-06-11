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

with Ada.Text_IO;
with Interfaces.C.Strings;
with XCB;


procedure Vision.Main is
   Connection : constant XCB.Connection_Access_Type
     := XCB.Connect (Interfaces.C.Strings.Null_Ptr);
   Screen : constant XCB.Screen_Access_Type
     := XCB.Setup_Roots_Iterator (XCB.Get_Setup (Connection)).Data;
   Window : constant XCB.Window_Id_Type
     := XCB.Generate_Id (Connection);

   Unused_Cookie : XCB.Void_Cookie_Type;
   pragma Unreferenced (Unused_Cookie);

   Unused_Int : Interfaces.C.int;
   pragma Unreferenced (Unused_Int);

begin
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

            when others =>
               null;
         end case;

         XCB.Free (Event);
         exit Main_Loop when Exiting;
      end;
   end loop Main_Loop;

end Vision.Main;
