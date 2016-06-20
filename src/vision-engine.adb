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

with Ada.Characters.Latin_1;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Vision.Display;

package body Vision.Engine is

   package Random_Directions is new Ada.Numerics.Discrete_Random
     (Directions.Enum);

   Generator : Random_Directions.Generator;
   Current_Direction : Directions.Enum;



   procedure Start is
   begin
      Random_Directions.Reset (Generator);
      Current_Direction := Random_Directions.Random (Generator);
      Display.Update (Current_Direction);
   end Start;


   procedure Stop is null;


   procedure User_Input (Direction : in Directions.Enum) is
   begin
      Ada.Text_IO.Put_Line
        (Directions.Enum'Image (Current_Direction)
         & Ada.Characters.Latin_1.HT
         & Directions.Enum'Image (Direction));
      Current_Direction := Random_Directions.Random (Generator);
      Display.Update (Current_Direction);
   end User_Input;

end Vision.Engine;
