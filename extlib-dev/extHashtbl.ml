(* 
 * ExtHashtbl, extra functions over hashtables.
 * Copyright (C) 2003 Nicolas Cannasse
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)
 

module Hashtbl =
  struct

	type ('a, 'b) h_bucketlist =
		| Empty
		| Cons of 'a * 'b * ('a, 'b) h_bucketlist

	type ('a, 'b) h_t = {
		mutable size: int;
		mutable data: ('a, 'b) h_bucketlist array
	}

	include Hashtbl

	external h_conv : ('a, 'b) t -> ('a, 'b) h_t = "%identity"
	external h_make : ('a, 'b) h_t -> ('a, 'b) t = "%identity"

	let exists = mem

	let enum h =
		let hdata = Array.copy (h_conv h).data in
		let rec make ipos ibuck icount =
			let pos = ref ipos in
			let buck = ref ibuck in
			let hcount = ref icount in
			let rec next() =
				match !buck with
				| Empty ->
					if !hcount = 0 then raise Enum.No_more_elements
					incr pos;
					next()
				| Cons (k,i,next_buck) ->
					buck := next_buck;
					decr hcount;
					(k,i)
			in
			let count() =
				!hcount
			in
			let clone() =
				make !pos !buck !hcount
			in
			Enum.make ~next ~count ~clone
		in		
		make (-1) Empty (h_conv h).size

	let keys h =
		Enum.map (fun (k,_) -> k) (enum h)

	let values h =
		Enum.map (fun (_,v) -> v) (enum h)

	let map f h =
		let rec loop = function
			| Empty -> Empty
			| Cons (k,v,next) -> Cons (k,f v,loop next)
		in
		h_make {
			size = (h_conv h).size;
			data = Array.map loop (h_conv h).data; 
		}

	let remove_all h key =
		let hc = h_conv h in
		let rec loop = function
			| Empty -> Empty
			| Cons(k,v,next) ->
				if k = key then begin
					hc.size <- pred hc.size;
					loop next
				end else
					Cons(k,v,loop next)
		in
		let pos = (hash key) mod (Array.length hc.data) in
		Array.unsafe_set hc.data pos (loop (Array.unsafe_get hc.data pos))

	let find_default h key defval =
		let rec loop = function
			| Empty -> defval
			| Cons (k,v,next) ->
				if k = key then v else loop next
		in
		let pos = (hash key) mod (Array.length (h_conv h).data) in
		loop (Array.unsafe_get (h_conv h).data pos)

	let of_enum e =
		let h = create (if Enum.fast_count e then Enum.count e else 0) in
		Enum.iter (fun (k,v) -> add h k v) e;
		h
	
	let count h =
		(h_conv h).size

  end